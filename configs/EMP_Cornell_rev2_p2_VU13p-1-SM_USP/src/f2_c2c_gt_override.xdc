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
#
# Anchor on 'gen_enabled_channel' to avoid matching any disabled lanes.
set_property LOC GTYE4_CHANNEL_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]

# Secondary C2C GT channel (F2_C2CB_PHY) -> GTYE4_CHANNEL_X1Y1
set_property LOC GTYE4_CHANNEL_X1Y1 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_CHANNEL" && NAME =~ "*c2cSlave_i*F2_C2CB_PHY*gen_enabled_channel*GTYE4_CHANNEL_PRIM_INST"}]

# NOTE (P2): Do not force a C2C GTYE4_COMMON LOC here.
# The TTC/TCDS2 relay owns the quad common in this build, and C2C is configured to
# request CPLL to avoid instantiating/placing a competing GTYE4_COMMON.
