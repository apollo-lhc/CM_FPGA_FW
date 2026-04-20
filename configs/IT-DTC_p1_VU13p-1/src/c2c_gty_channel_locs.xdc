# Force deterministic GTY channel placement for the two C2C Aurora PHYs.
#
# Rationale: Vivado/IP can emit fixed LOCs in generated *_gt.xdc. If two Aurora instances
# auto-select the same GTYE4_CHANNEL site, implementation fails with:
#   - [Vivado 12-2285] Cannot set LOC ... bel is occupied ... (GTYE4_CHANNEL_X1Y0)
#   - [Place 30-738] Unroutable Placement! GTYE_COMMON / GTYE_CHANNEL not routable
#
# These constraints are read from configs/.../files.tcl after IP constraints,
# so they override the generated defaults.

# Primary C2C link (known-good): X1Y0
set_property LOC GTYE4_CHANNEL_X1Y0 \
  [get_cells -hierarchical -filter {NAME =~ *F1_C2C_PHY*GTYE4_CHANNEL_PRIM_INST}]

# Secondary C2C "B" link: steer to the other channel in the quad (X1Y1)
set_property LOC GTYE4_CHANNEL_X1Y1 \
  [get_cells -hierarchical -filter {NAME =~ *F1_C2CB_PHY*GTYE4_CHANNEL_PRIM_INST}]
