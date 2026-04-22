# Applied just before place_design to force final GT LOCs.
#
# This runs with the design open, after IP-generated constraints have been read,
# so it reliably overrides hard-LOCs from GT wizard *_gt.xdc.

# NOTE: Some CI log captures only show WARNING/ERROR lines. Emit a single
# WARNING banner so we can confirm this hook executed.
puts "WARNING: f2_c2c_gt_preplace.tcl: running pre-place GT LOC enforcement"

proc _warn {msg} {
	puts "WARNING: f2_c2c_gt_preplace.tcl: $msg"
}

proc _safe_get_property {prop obj} {
	set v ""
	catch {set v [get_property -quiet $prop $obj]}
	return $v
}

proc _site_clock_region {site_name} {
	if {$site_name eq ""} {
		return ""
	}
	set sites [get_sites -quiet $site_name]
	if {[llength $sites] == 0} {
		return ""
	}
	set cr ""
	catch {set cr [get_property -quiet CLOCK_REGION $sites]}
	return $cr
}

proc _cell_loc_cr {cell} {
	set loc [_safe_get_property LOC $cell]
	if {$loc eq ""} {
		# Some flows may only have SITE set.
		set loc [_safe_get_property SITE $cell]
	}
	set cr [_site_clock_region $loc]
	return [list $loc $cr]
}

proc _cell_pblocks {cell} {
	set pbs [get_pblocks -quiet -of_objects $cell]
	if {[llength $pbs] == 0} {
		return ""
	}
	# Typically 0 or 1 pblock, but join just in case.
	set names [list]
	foreach pb $pbs {
		lappend names [_safe_get_property NAME $pb]
	}
	return [join $names ","]
}

proc _fanin_commons_for_pin {pin} {
	# Return list of GTYE4_COMMON cells that drive this pin (via all_fanin).
	set commons [list]
	set startpts [list]
	catch {set startpts [all_fanin -to $pin -flat -startpoints_only -quiet]}
	if {[llength $startpts] == 0} {
		return $commons
	}
	catch {set commons [get_cells -quiet -of_objects $startpts -filter {REF_NAME == "GTYE4_COMMON"}]}
	return $commons
}

proc _net_name_of_pin {pin} {
	set n [get_nets -quiet -of_objects $pin]
	if {[llength $n] == 0} {
		return ""
	}
	return [_safe_get_property NAME $n]
}

proc _report_c2c_refclk_summary {} {
	# Emit a short summary tying together:
	#  - where IBUFDS_GTE4 refclks are constrained/placed (LOC + CLOCK_REGION)
	#  - which GTREFCLK/QPLL pins are actually connected for the two C2C channels
	# This helps rule out missing/misplaced refclk buffering as a cause of [Place 30-738].
	_warn "C2C refclk summary: IBUFDS_GTE4 + C2C channel refclk pins"

	set ibufs [get_cells -hierarchical -quiet -filter {REF_NAME == "IBUFDS_GTE4"}]
	foreach c $ibufs {
		lassign [_cell_loc_cr $c] loc cr
		set i_net ""
		set ib_net ""
		set o_net ""
		set odiv2_net ""
		set i_pin [get_pins -quiet -of_objects $c -filter {REF_PIN_NAME == "I"}]
		set ib_pin [get_pins -quiet -of_objects $c -filter {REF_PIN_NAME == "IB"}]
		set o_pin [get_pins -quiet -of_objects $c -filter {REF_PIN_NAME == "O"}]
		set odiv2_pin [get_pins -quiet -of_objects $c -filter {REF_PIN_NAME == "ODIV2"}]
		if {[llength $i_pin] > 0} { set i_net [_net_name_of_pin [lindex $i_pin 0]] }
		if {[llength $ib_pin] > 0} { set ib_net [_net_name_of_pin [lindex $ib_pin 0]] }
		if {[llength $o_pin] > 0} { set o_net [_net_name_of_pin [lindex $o_pin 0]] }
		if {[llength $odiv2_pin] > 0} { set odiv2_net [_net_name_of_pin [lindex $odiv2_pin 0]] }
		_warn "IBUFDS_GTE4 cell=$c LOC=$loc CR=$cr I=$i_net IB=$ib_net O=$o_net ODIV2=$odiv2_net"
	}

	set channels [list]
	set ch_a [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set ch_b [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set channels [concat $ch_a $ch_b]
	if {[llength $channels] == 0} {
		_warn "C2C refclk summary: no C2C GTYE4_CHANNEL cells found"
		return
	}

	foreach ch $channels {
		lassign [_cell_loc_cr $ch] ch_loc ch_cr
		set pins [get_pins -quiet -of_objects $ch -filter {
			REF_PIN_NAME == "GTREFCLK0" ||
			REF_PIN_NAME == "GTREFCLK1" ||
			REF_PIN_NAME == "QPLL0CLK" ||
			REF_PIN_NAME == "QPLL0REFCLK" ||
			REF_PIN_NAME == "QPLL1CLK" ||
			REF_PIN_NAME == "QPLL1REFCLK"
		}]
		foreach p $pins {
			set rp [_safe_get_property REF_PIN_NAME $p]
			set nn [_net_name_of_pin $p]
			_warn "C2C refclk summary: CHANNEL=$ch LOC=$ch_loc CR=$ch_cr pin=$rp net=$nn"
		}
	}
}

proc _report_gt_qpll_pairs {} {
	# Print COMMON<->CHANNEL pairings implied by QPLL nets, with LOC + CLOCK_REGION.
	# This helps pinpoint exactly which pair triggers [Place 30-738] when Vivado
	# does not print the offending instance names in CI logs.
	_warn "GT QPLL connectivity diagnostic: scanning GTYE4_CHANNEL QPLL nets"

	# Restrict to the two C2C GT channels to keep logs short and relevant.
	set channels [list]
	set ch_a [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set ch_b [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set channels [concat $ch_a $ch_b]
	if {[llength $channels] == 0} {
		_warn "GT QPLL connectivity diagnostic: no GTYE4_CHANNEL cells found"
		return
	}

	foreach ch $channels {
		# Pin NAME can vary with hierarchy; REF_PIN_NAME is stable.
		set qpll_pins [get_pins -quiet -of_objects $ch -filter {REF_PIN_NAME =~ "QPLL*CLK" || REF_PIN_NAME =~ "QPLL*REFCLK"}]
		if {[llength $qpll_pins] == 0} {
			set maybe [get_pins -quiet -of_objects $ch -filter {REF_PIN_NAME =~ "QPLL*"}]
			_warn "GT QPLL diagnostic: channel=$ch has no QPLL*CLK/QPLL*REFCLK pins (QPLL* pins found: [llength $maybe])"
			continue
		}

		foreach p $qpll_pins {
			set pin_name [_safe_get_property REF_PIN_NAME $p]

			# First try: walk up the logic cone so we can cross hierarchy ports.
			set commons [list]
			set startpts [list]
			catch {set startpts [all_fanin -to $p -flat -startpoints_only -quiet]}
			if {[llength $startpts] > 0} {
				catch {set commons [get_cells -quiet -of_objects $startpts -filter {REF_NAME == "GTYE4_COMMON"}]}
			}

			# Fallback: look at the immediate net (may miss COMMON if it connects via ports).
			set n [get_nets -quiet -of_objects $p]
			set net_name ""
			set net_pins [list]
			if {[llength $n] > 0} {
				set net_name [_safe_get_property NAME $n]
				set net_pins [get_pins -quiet -of_objects $n]
				if {[llength $commons] == 0} {
					catch {set commons [get_cells -quiet -of_objects $net_pins -filter {REF_NAME == "GTYE4_COMMON"}]}
				}
			}

			if {[llength $commons] == 0} {
				if {$net_name eq ""} {
					_warn "GT QPLL diagnostic: channel=$ch pin=$pin_name has no net and no COMMON found via all_fanin"
				} else {
					_warn "GT QPLL diagnostic: channel=$ch pin=$pin_name net=$net_name has no GTYE4_COMMON (all_fanin_startpts=[llength $startpts], net_pins=[llength $net_pins])"
				}
				continue
			}

			foreach c $commons {
				lassign [_cell_loc_cr $c] c_loc c_cr
				lassign [_cell_loc_cr $ch] ch_loc ch_cr
				_warn "GT QPLL pin=$pin_name net=$net_name COMMON=$c LOC=$c_loc CR=$c_cr -> CHANNEL=$ch LOC=$ch_loc CR=$ch_cr"
			}
		}
	}
}

proc _report_gt_qpll_pairs_global {} {
	# Scan *all* GTYE4_CHANNELs and report only suspicious COMMON<->CHANNEL pairings.
	# This is aimed at identifying the real culprit behind [Place 30-738] when
	# Vivado doesn't print the offending instances.
	_warn "GT QPLL global diagnostic: scanning all GTYE4_CHANNEL cells (reporting only risky pairs)"

	set channels [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL"}]
	if {[llength $channels] == 0} {
		_warn "GT QPLL global diagnostic: no GTYE4_CHANNEL cells found"
		return
	}

	set risky 0
	set examined 0
	foreach ch $channels {
		incr examined
		set ch_pins [list]
		# Prefer QPLL1 pins; fall back to QPLL0 if QPLL1 yields nothing.
		set qpll1_pins [get_pins -quiet -of_objects $ch -filter {REF_PIN_NAME == "QPLL1CLK" || REF_PIN_NAME == "QPLL1REFCLK"}]
		set qpll0_pins [get_pins -quiet -of_objects $ch -filter {REF_PIN_NAME == "QPLL0CLK" || REF_PIN_NAME == "QPLL0REFCLK"}]
		if {[llength $qpll1_pins] > 0} {
			set ch_pins $qpll1_pins
		} elseif {[llength $qpll0_pins] > 0} {
			set ch_pins $qpll0_pins
		} else {
			continue
		}

		# Determine the common(s) that feed this channel's QPLL inputs.
		set commons [list]
		set pin_used ""
		set net_name ""
		foreach p $ch_pins {
			set pin_used [_safe_get_property REF_PIN_NAME $p]
			set net_name [_net_name_of_pin $p]
			# Skip obvious tie-offs to keep output stable/short.
			if {[string match "*<const*>" $net_name]} {
				continue
			}
			set commons [_fanin_commons_for_pin $p]
			if {[llength $commons] > 0} {
				break
			}
		}
		if {[llength $commons] == 0} {
			continue
		}

		lassign [_cell_loc_cr $ch] ch_loc ch_cr
		set ch_pb [_cell_pblocks $ch]

		foreach c $commons {
			lassign [_cell_loc_cr $c] c_loc c_cr
			set c_pb [_cell_pblocks $c]

			# If neither side has a LOC yet, this is fully unplaced/unconstrained and
			# will be decided by the placer. Reporting these in CI produces too much noise.
			if {$ch_loc eq "" && $c_loc eq ""} {
				continue
			}

			set reason ""
			if {$ch_loc eq ""} {
				append reason "channel_LOC_missing;"
			}
			if {$c_loc eq ""} {
				append reason "common_LOC_missing;"
			}
			if {$ch_cr ne "" && $c_cr ne "" && $ch_cr ne $c_cr} {
				append reason "clock_region_mismatch(${c_cr}->${ch_cr});"
			}

			# Only print risky cases to avoid bloating CI logs.
			if {$reason ne ""} {
				incr risky
				_warn "GT QPLL global risk: reason=${reason} pin=${pin_used} net=${net_name} COMMON=${c} LOC=${c_loc} CR=${c_cr} PBLOCK=${c_pb} -> CHANNEL=${ch} LOC=${ch_loc} CR=${ch_cr} PBLOCK=${ch_pb}"
			}
		}
	}

	_warn "GT QPLL global diagnostic: examined_channels=${examined} risky_pairs=${risky}"
}

proc _set_loc_if_found {ref_name name_glob loc} {
	set cells [get_cells -hierarchical -quiet -filter [format {REF_NAME == "%s" && NAME =~ "%s"} $ref_name $name_glob]]
	if {[llength $cells] == 0} {
		_warn "no cells matched (REF_NAME=$ref_name, NAME~= $name_glob)"
		return
	}
	_warn "setting LOC=$loc on [llength $cells] cell(s) (REF_NAME=$ref_name, NAME~= $name_glob)"
	set_property LOC $loc $cells
}

# Secondary C2C GT channel (F2_C2CB_PHY)
_set_loc_if_found GTYE4_CHANNEL {*c2cSlave_i*F2_C2CB_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST} GTYE4_CHANNEL_X1Y1

# Primary C2C GT channel (F2_C2C_PHY)
# Anchor on 'gen_enabled_channel' to avoid matching disabled lanes.
_set_loc_if_found GTYE4_CHANNEL {*c2cSlave_i*F2_C2C_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST} GTYE4_CHANNEL_X1Y0

# Shared C2C GT COMMON (under F2_C2C_PHY) must be in the same quad as the channels.
# Enforce this late so it reliably overrides any IP-generated *_gt.xdc constraints.
_set_loc_if_found GTYE4_COMMON {*c2cSlave_i*F2_C2C_PHY*GTYE4_COMMON_PRIM_INST} GTYE4_COMMON_X1Y0

# TTC/TCDS2 relay GT COMMON must match the (PBLOCK-forced) TTC channel quad.
# See impl log evidence: ttc/.../tcds2_interface_mgt_common/.../GTYE4_COMMON_PRIM_INST had blank LOC
# while the TTC channel was forced to GTYE4_CHANNEL_X1Y3 in PBLOCK quad_R0.
_set_loc_if_found GTYE4_COMMON {*ttc/gen_master_tcds2.if_tcds2_interface_lw.tcds2_interface_mgt_common*common_inst/gtye4_common_gen.GTYE4_COMMON_PRIM_INST} GTYE4_COMMON_X1Y0

# Optional last-resort experiment:
# Allow the QPLL clock nets feeding the C2C channel(s) to use non-dedicated routing.
# This can sometimes let the placer move the C2C COMMON to a different quad (freeing
# the TTC-owned quad common), at the cost of timing/jitter risk.
#
# Enable by setting an environment variable before running Vivado:
#   export CM_RELAX_C2C_QPLL_DEDICATED_ROUTE=1
if {[info exists ::env(CM_RELAX_C2C_QPLL_DEDICATED_ROUTE)] && $::env(CM_RELAX_C2C_QPLL_DEDICATED_ROUTE) ne "" && $::env(CM_RELAX_C2C_QPLL_DEDICATED_ROUTE) ne "0"} {
	_warn "CM_RELAX_C2C_QPLL_DEDICATED_ROUTE is set: relaxing CLOCK_DEDICATED_ROUTE on C2C QPLL nets (EXPERIMENTAL)"
	set c2c_channels [list]
	set ch_a [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set ch_b [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]
	set c2c_channels [concat $ch_a $ch_b]
	set qpll_nets [list]
	foreach ch $c2c_channels {
		set qpll_pins [get_pins -quiet -of_objects $ch -filter {REF_PIN_NAME =~ "QPLL*CLK" || REF_PIN_NAME =~ "QPLL*REFCLK"}]
		foreach p $qpll_pins {
			set n [get_nets -quiet -of_objects $p]
			if {[llength $n] > 0} {
				set qpll_nets [concat $qpll_nets $n]
			}
		}
	}
	set qpll_nets [lsort -unique $qpll_nets]
	if {[llength $qpll_nets] == 0} {
		_warn "CM_RELAX_C2C_QPLL_DEDICATED_ROUTE: no QPLL nets found on C2C channels"
	} else {
		set_property -quiet CLOCK_DEDICATED_ROUTE FALSE $qpll_nets
		_warn "CM_RELAX_C2C_QPLL_DEDICATED_ROUTE: set CLOCK_DEDICATED_ROUTE=FALSE on [llength $qpll_nets] net(s)"
		foreach n $qpll_nets {
			_warn "  relaxed: [_safe_get_property NAME $n]"
		}
	}
}

# Emit COMMON<->CHANNEL mapping so the CI log tells us which pair is illegal.
_report_c2c_refclk_summary
_report_gt_qpll_pairs

# Also scan the rest of the design; [Place 30-738] may be triggered by a
# different GT pair than the two C2C lanes.
_report_gt_qpll_pairs_global
