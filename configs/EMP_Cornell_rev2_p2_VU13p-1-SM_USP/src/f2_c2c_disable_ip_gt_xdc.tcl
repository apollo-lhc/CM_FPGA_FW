# Disable IP-generated GT Wizard hard-LOC constraints for the two C2C PHYs.
#
# This script is intended to run as STEPS.INIT_DESIGN.TCL.PRE so it executes
# before implementation reads XDC constraints, preventing LOC collisions and
# illegal COMMON<->CHANNEL pairings being forced by *_gt.xdc.

set gt_xdc_patterns [list \
	"*c2cSlave_F2_C2C_PHY_0_gt.xdc" \
	"*c2cSlave_F2_C2CB_PHY_0_gt.xdc" \
]

foreach pat $gt_xdc_patterns {
	set gt_files [get_files -all -quiet $pat]
	if {[llength $gt_files] == 0} {
		puts "WARNING: f2_c2c_disable_ip_gt_xdc.tcl: no GT XDC files matched pattern: $pat"
		continue
	}

	foreach f $gt_files {
		set_property USED_IN_SYNTHESIS 0 $f
		set_property USED_IN_IMPLEMENTATION 0 $f
	}
	puts "INFO: f2_c2c_disable_ip_gt_xdc.tcl: disabled IP GT constraint file(s): $gt_files"
}
