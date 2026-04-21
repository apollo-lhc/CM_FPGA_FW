# Add late-applied XDC overrides for the F2 C2C GT placement.
#
# This is used from the EMP *.dep flow via a `setup` directive.
# We add the XDC to constrs_1 with PROCESSING_ORDER=LATE so it overrides
# IP-generated *_gt.xdc constraints.

set this_dir [file dirname [info script]]
set xdc_path [file normalize [file join $this_dir "f2_c2c_gt_override.xdc"]]

if {![file exists $xdc_path]} {
	puts "WARNING: f2_c2c_gt_override.tcl: XDC not found: $xdc_path"
	return
}

# Add to project constraints; do not read immediately.
add_files -fileset constrs_1 $xdc_path

# Ensure it is applied late.
set xdc_file_obj [get_files $xdc_path]
if {[llength $xdc_file_obj] > 0} {
	set_property PROCESSING_ORDER LATE $xdc_file_obj
	set_property USED_IN_SYNTHESIS 1 $xdc_file_obj
	set_property USED_IN_IMPLEMENTATION 1 $xdc_file_obj
}

puts "INFO: Added F2 C2C GT override constraints (LATE): $xdc_path"

# Disable IP-generated GT Wizard hard-LOC constraints for these two PHYs.
#
# Rationale:
# - The Aurora/GT Wizard emits per-IP *_gt.xdc files that hard-pin GT sites.
# - With two C2C links, those generated LOCs can collide or force an illegal
#   COMMON<->CHANNEL pairing.
# - We instead rely on the deterministic late-applied overrides above.
set gt_xdc_patterns [list \
	"*c2cSlave_F2_C2C_PHY_0_gt.xdc" \
	"*c2cSlave_F2_C2CB_PHY_0_gt.xdc" \
]

foreach pat $gt_xdc_patterns {
	set gt_files [get_files -all -quiet $pat]
	if {[llength $gt_files] == 0} {
		puts "WARNING: f2_c2c_gt_override.tcl: no GT XDC files matched pattern: $pat"
		continue
	}

	foreach f $gt_files {
		# Ensure these constraints are not used for this build.
		set_property USED_IN_SYNTHESIS 0 $f
		set_property USED_IN_IMPLEMENTATION 0 $f
	}
	puts "INFO: Disabled IP GT constraint file(s): $gt_files"
}
