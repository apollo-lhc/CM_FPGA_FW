# F2 C2C GT placement overrides (P2 builds)
#
# Purpose:
# - Override Aurora/GT Wizard generated *_gt.xdc hard-LOCs that can collide when
#   multiple GT users share a quad.
# - Enforce deterministic placement for the two AXI C2C 10G links on Quad L.
#
# Notes:
# - This file is intentionally written as "pure constraints" (no Tcl control
#   flow like 'if'). Some build flows parse XDCs in a restricted mode where Tcl
#   control-flow is rejected.

# Primary C2C GT channel (F2_C2C_PHY) -> GTYE4_CHANNEL_X1Y0
set_property LOC GTYE4_CHANNEL_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*GTYE4_CHANNEL_PRIM_INST"}]

# Secondary C2C GT channel (F2_C2CB_PHY) -> GTYE4_CHANNEL_X1Y1
set_property LOC GTYE4_CHANNEL_X1Y1 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*GTYE4_CHANNEL_PRIM_INST"}]

# Pin the common/QPLL for the primary link into the matching quad.
# (The secondary link is expected to share this common/QPLL.)
set_property LOC GTYE4_COMMON_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_COMMON" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*GTYE4_COMMON_PRIM_INST"}]

# Some Aurora/GT Wizard configurations may still instantiate a GT common under the
# secondary PHY wrapper. If present, force it into the same quad common site.
set_property LOC GTYE4_COMMON_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_COMMON" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*GTYE4_COMMON_PRIM_INST"}]
