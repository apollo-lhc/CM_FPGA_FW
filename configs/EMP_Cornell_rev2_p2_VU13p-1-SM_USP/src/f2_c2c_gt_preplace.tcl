# Applied just before place_design to force final GT LOCs.
#
# This runs with the design open, after IP-generated constraints have been read,
# so it reliably overrides hard-LOCs from GT wizard *_gt.xdc.

proc _set_loc_if_found {ref_name name_glob loc} {
	set cells [get_cells -hierarchical -quiet -filter [format {REF_NAME == "%s" && NAME =~ "%s"} $ref_name $name_glob]]
	if {[llength $cells] == 0} {
		puts "WARNING: f2_c2c_gt_preplace.tcl: no cells matched (REF_NAME=$ref_name, NAME~= $name_glob)"
		return
	}
	puts "INFO: f2_c2c_gt_preplace.tcl: setting LOC=$loc on [llength $cells] cell(s) (REF_NAME=$ref_name, NAME~= $name_glob)"
	set_property LOC $loc $cells
}

# Primary C2C GT channel (F2_C2C_PHY)
_set_loc_if_found GTYE4_CHANNEL *c2cSlave_i*F2_C2C_PHY*GTYE4_CHANNEL_PRIM_INST GTYE4_CHANNEL_X1Y0

# Secondary C2C GT channel (F2_C2CB_PHY)
_set_loc_if_found GTYE4_CHANNEL *c2cSlave_i*F2_C2CB_PHY*GTYE4_CHANNEL_PRIM_INST GTYE4_CHANNEL_X1Y1

# Common/QPLL for the quad
_set_loc_if_found GTYE4_COMMON *c2cSlave_i*F2_C2C_PHY*GTYE4_COMMON_PRIM_INST GTYE4_COMMON_X1Y0
