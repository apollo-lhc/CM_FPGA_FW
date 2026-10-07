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

# Shared C2C GTYE4_COMMON -> GTYE4_COMMON_X1Y0
#
# Rationale:
# - Both C2C channels above are pinned to Quad L (X1Y0/X1Y1).
# - The channels are fed by a shared GTYE4_COMMON instantiated under F2_C2C_PHY
#   (see pre-place hook diagnostics in CI logs).
# - For dedicated QPLL clocking, the COMMON must be in the *same quad* as the channels;
#   otherwise Vivado fails with [Place 30-738].
set_property LOC GTYE4_COMMON_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_COMMON" && NAME =~ "*c2cSlave_i*F2_C2C_PHY*GTYE4_COMMON_PRIM_INST"}]

# TTC/TCDS2 relay: constrain the GTYE4_COMMON that feeds the TTC GTY channel(s).
#
# Context:
# - The TTC channel is forced into PBLOCK quad_R0 (e.g. GTYE4_CHANNEL_X1Y3).
# - If the paired COMMON floats, Vivado can place it in a different clock region,
#   triggering [Place 30-738] rule_gtycommon_gtychannel.
#
# For GTYE4 channels X1Y0..X1Y3, the matching COMMON is GTYE4_COMMON_X1Y0.
set_property LOC GTYE4_COMMON_X1Y0 \
  [get_cells -hierarchical -filter {REF_NAME == "GTYE4_COMMON" && NAME =~ "*ttc/gen_master_tcds2.if_tcds2_interface_lw.tcds2_interface_mgt_common*common_inst/gtye4_common_gen.GTYE4_COMMON_PRIM_INST"}]
