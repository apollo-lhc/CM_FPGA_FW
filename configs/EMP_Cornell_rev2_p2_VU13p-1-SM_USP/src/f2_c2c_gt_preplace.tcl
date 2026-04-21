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

proc _report_gt_qpll_pairs {} {
	# Print COMMON<->CHANNEL pairings implied by QPLL nets, with LOC + CLOCK_REGION.
	# This helps pinpoint exactly which pair triggers [Place 30-738] when Vivado
	# does not print the offending instance names in CI logs.
	_warn "GT QPLL connectivity diagnostic: scanning GTYE4_CHANNEL QPLL nets"

	set channels [get_cells -hierarchical -quiet -filter {REF_NAME == "GTYE4_CHANNEL"}]
	if {[llength $channels] == 0} {
		_warn "GT QPLL connectivity diagnostic: no GTYE4_CHANNEL cells found"
		return
	}

	foreach ch $channels {
		set qpll_pins [get_pins -quiet -of_objects $ch -filter {NAME =~ "*/QPLL*CLK" || NAME =~ "*/QPLL*REFCLK"}]
		if {[llength $qpll_pins] == 0} {
			continue
		}

		foreach p $qpll_pins {
			set n [get_nets -quiet -of_objects $p]
			if {[llength $n] == 0} {
				continue
			}
			# Find any GTYE4_COMMON cells on this net.
			set net_pins [get_pins -quiet -of_objects $n]
			set commons [get_cells -quiet -of_objects $net_pins -filter {REF_NAME == "GTYE4_COMMON"}]
			if {[llength $commons] == 0} {
				continue
			}

			foreach c $commons {
				lassign [_cell_loc_cr $c] c_loc c_cr
				lassign [_cell_loc_cr $ch] ch_loc ch_cr
				set pin_name [_safe_get_property NAME $p]
				set net_name [_safe_get_property NAME $n]
				_warn "GT QPLL net=$net_name pin=$pin_name COMMON=$c LOC=$c_loc CR=$c_cr -> CHANNEL=$ch LOC=$ch_loc CR=$ch_cr"
			}
		}
	}
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

# Common/QPLL for the quad
_set_loc_if_found GTYE4_COMMON *c2cSlave_i*F2_C2C_PHY*GTYE4_COMMON_PRIM_INST GTYE4_COMMON_X1Y0

# Emit COMMON<->CHANNEL mapping so the CI log tells us which pair is illegal.
_report_gt_qpll_pairs
