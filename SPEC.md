# SPEC

## Current status (baseline inherited from c2c_dma_jrf_128_to_64)

This branch derives from the known-good 8 Gb/s C2C bandwidth-test baseline for the EMP Cornell Rev2 CM builds. It keeps the full AXI C2C datapath at 64-bit width, moves the shared EMP AXI master clock to 100 MHz, and uses one Aurora lane per C2C link with per-channel CPLL clocking. The production endpoint layout now omits scratch RAM and requires fresh build and hardware validation; see README.md for the preserved diagnostic baseline.

C2C / AXI-C2C datapath (`axi_chip2chip` + external `aurora_64b66b`):
- 1-lane AXI4 C2C links use `speed: 8`, `gt_pll: cpll`, `refclk_freq: 200`, and `primary_serdes: 1`.
- Full AXI C2C links use `axi_data_width: 64`.
- AXI-Lite C2CB links use `axi_data_width: 32` and remain separate from the full AXI path. On `feature/c2c_axilite_lane_merge`, each FPGA's register traffic moves onto the AXI4-Lite channel of its full AXI link (`F1_C2C`/`F2_C2C`; work item 3, stage 1); the C2CB links stay instantiated and connected.
- Known-good configuration uses Compact 2-1 mode from the generated AXI C2C IP; `CONFIG.C_AURORA_WIDTH` is derived/locked.
- Link handler enabled (`CONFIG.C_EN_AXI_LINK_HNDLR = true`).

Historical measurements on the scratch-enabled 64-bit AXI baseline (not validation of the scratch-removal change):
- IPbus-to-BRAM sustained throughput: ~380 Mbps (previously ~160 Mbps write-only).
- Native AXI write sustained throughput: ~700 Mbps.

Primary branch wiring:
- `EMP_Cornell_rev2_p1_VU13p-1-SM_USP` includes `src/CM_yaml/CM_C2C/Cornell_rev2_p1_C2C_8g.yaml`.
- `EMP_Cornell_rev2_p2_VU13p-1-SM_USP` includes `src/CM_yaml/CM_C2C/Cornell_rev2_p2_C2C_8g.yaml`.
- The EMP base AXI master clock is 100 MHz.
- F1/F2 IPbus address windows are 16 MiB on the full AXI endpoint path; this does not specify transport buffer depth.
- F1/F2 scratch RAM endpoints are omitted in production. Their former 1 MiB, 64-bit BRAM-backed implementation is preserved on `backup/c2c-8g-scratch-before-release-20261007` for future native-AXI development.

## Work items

The scratch-dependent work below is future development, not part of this release.
Reintroducing scratch requires restoring a non-overlapping address layout first.

1. [ ] CM_FPGA_FW: Align AXI4 datapath with SM_ZYNQ_FW (8 Gbps PHY, AXI-C2C @ 200 MHz)

   - [ ] Baseline
     - [ ] Current far-end FPGA (CM_FPGA_FW):
       - Aurora link configured for 8 Gbps operation (200 MHz refclk)
       - C2C1 / C2C2 operating in Compact 2-1 mode
       - AXI fabric clock observed at 100 MHz
       - CM_INTERCONNECT:
         - Advanced options disabled
         - XBAR width = 32-bit
       - AXI4 data width = 64-bit (current)
       - AXI-Lite path exists (C2C1B / C2C2B)

   - [ ] Objective
     - [ ] Upgrade far-end design to match the near-end gearbox approach (AXI4 only):
       - Keep Aurora PHY at 8 Gbps (200 MHz refclk)
       - Run AXI-C2C (AXI4) at 64-bit @ 200 MHz
       - Convert AXI4 from 200 MHz to 100 MHz for the local fabric via AXI Clock Converter
       - Widen AXI4 local fabric to 128-bit @ 100 MHz via AXI Data Width Converter
       - Set CM_INTERCONNECT XBAR width to 128-bit @ 100 MHz
       - Update F1_SCRATCH_RAM and F2_SCRATCH_RAM to 128-bit @ 100 MHz (initial throughput test)
       - Keep AXI-Lite path unchanged (clocking, width, and topology)

   - [x] Aurora PHY Upgrade
     - [x] Reconfigure Aurora cores to:
       - Line rate: 8 Gbps
       - PLL: CPLL
       - Lanes: 1
       - Maintain Compact 2-1 mode
     - [x] Use 200 MHz reference clock in the C2C YAML.
     - [x] Add P2 GT placement/pre-place handling for the C2C channel.
     - [x] Verify:
       - GT configuration matches near-end FPGA
       - Lane configuration consistent with near-end (1 or 2 lanes as required)
       (On hardware, the F1 and F2 links come up at 8 Gb/s with one lane each:
       cmsapollo3022 on 2026-09-19, and apollo212-1 FPGA1 on 2026-10-11 to 13.)

   - [ ] Clocking (AXI4 split domains)
     - [ ] Add Clocking Wizard to generate AXI-C2C clock:
       - Output: 200 MHz (AXI-C2C AXI4 clock)
       - Use `locked` for reset sequencing
     - [x] Keep existing AXI fabric clock at 100 MHz for local AXI4 interconnect and slaves
       (`clk_200` divided by `BUFGCE_DIV` in the EMP `sub_module.vhd`; `AXI_MASTER`
       is 100 MHz in `EMP_base.yaml`.)
     - [ ] Ensure AXI4-only clock domain crossings are explicit (AXI Clock Converter)

   - [ ] Reset Strategy (AXI4 domains)
     - [ ] Add/reset a Processor System Reset for 200 MHz AXI-C2C domain:
       - `slowest_sync_clk` → 200 MHz
       - `ext_reset_in` → existing external reset
       - `dcm_locked` → Clocking Wizard `locked`
       - Use `peripheral_aresetn` for AXI-C2C + converters in the 200 MHz domain
     - [x] Keep/confirm reset generation for 100 MHz AXI fabric domain
       (`SYS_RESET`, a `proc_sys_reset` on the 100 MHz `AXI_MASTER_CLK`, released
       by the 200 MHz MMCM lock; checked 2026-10-14.)

   - [ ] AXI4 Infrastructure Update
     - [ ] AXI-C2C (AXI4) domain @ 200 MHz:
       - 64-bit AXI width
       - C2C1 / C2C2 AXI4 clocked from 200 MHz
     - [ ] AXI4 fabric domain @ 100 MHz:
       - 128-bit AXI width on CM_INTERCONNECT and scratch RAM endpoints
       - Insert AXI Data Width Converter (64 → 128) on the 100 MHz side
       - Insert AXI Clock Converter (200 → 100) between C2C and CM_INTERCONNECT
     - [ ] CM_INTERCONNECT tuning (match SM_ZYNQ_FW tactics as applicable):
       - Enable Advanced Configuration Options
       - Set XBAR width to 128-bit
       - Apply data FIFO / register slice placement on the AXI4 ports carrying bulk traffic

   - [ ] Endpoint Throughput Validation (initial)
     - [ ] Verify the scratch RAM endpoints can sustain:
       - 128-bit @ 100 MHz
     - [ ] Check:
       - BRAM / URAM interfaces
       - Register blocks (ensure no unintended throttling)
     - [ ] Identify any slow peripherals and isolate if needed

   - [ ] C2C Interface Alignment
     - [ ] Ensure C2C1 / C2C2 (AXI4):
       - AXI clock = 200 MHz
       - AXI width = 64-bit
       - Configuration matches near-end FPGA
     - [ ] Do NOT modify:
       - AXI-Lite links (C2C1B / C2C2B)

   - [ ] Clock Domain Consistency
     - [ ] Ensure AXI4 uses exactly two explicit domains:
       - 200 MHz for AXI-C2C AXI4
       - 100 MHz for local AXI4 fabric
     - [ ] Ensure there are no unintended implicit crossings (Vivado auto-inserted converters)

   - [ ] Validation
     - [ ] Verify clocks:
       - 200 MHz AXI-C2C present and stable
       - 100 MHz AXI fabric present and stable
     - [ ] Verify AXI:
       - No protocol violations
       - No timing failures
     - [x] Verify Aurora:
       - Link up at 8 Gbps
       - No lane mismatch with near-end
       (Same hardware evidence as the Aurora PHY check above.)
     - [ ] End-to-end:
       - Sustained throughput matches expected bandwidth

   - [ ] Do NOT Modify
     - [ ] AXI-Lite topology, clocks, and widths
     - [ ] C2C protocol-level behavior (Compact 2-1, link handler)
     - [ ] Functional behavior of endpoints

   - [ ] Intent
     - [ ] Align far-end FPGA with near-end gearbox architecture (AXI4 path)
     - [ ] Remove bandwidth bottlenecks from narrow/slow local interconnect configuration
     - [ ] Enable higher utilization of the 8 Gbps Aurora link

   - [ ] Deliverables
     - [x] Updated YAML block design description
     - [x] Updated Python/TCL generation support via submodule updates
     - [x] Updated TCL:
       - clocking changes
       - reset generation
       - AXI reconnection
       - design validation

2. [ ] TODO (parked): Re-validate UART endpoint + device-tree clock metadata

   Context / hypothesis to revisit:
   - The C2C UART endpoint (e.g. `CM1_PB_UART`) carries YAML-provided `dt_data` that includes a hard-coded AXI clock frequency (seen as ~50 MHz, e.g. `xlnx,s-axi-aclk-freq-hz-d = "49.9995"`).
   - Our current intent for EMP builds is AXI fabric @ 100 MHz; the DT metadata may be stale/misleading and could affect Linux-side UART behavior (driver baud/divisor assumptions), even if the HDL clocking is correct.

   Guardrails for upcoming debugging:
   - [ ] First get back to a baseline build that works again (no functional/BD refactors).
   - [ ] Then make surgical changes one-at-a-time, validating each step.

   Re-validation checklist (when we return to this item):
   - [ ] Generate DTSI/DTBO artifacts for the target EMP config and locate the UART node/overlay under `kernel/hw/<build_name>/`.
   - [ ] Confirm which clock frequency properties are emitted for the UART endpoint and whether they match the actual AXI clock domain used.
   - [ ] Confirm the UART endpoint still works end-to-end (Linux-visible + functional I/O) after the baseline is restored.

3. [ ] AXI-Lite on the AXI4 C2C lane (one C2C lane per FPGA)

   The full rationale, the SM side, the compatibility table and the soak/recovery
   plan are in `SM_ZYNQ_FW` `SPEC.md`, "Independent workstream: AXI-Lite on the
   AXI4 C2C lane". Decided on 2026-10-14:
   - Carry each FPGA's register traffic on the Chip2Chip AXI4-Lite channel of its
     AXI4 lane (`F1_C2C`/`F2_C2C`) instead of the separate AXI-Lite lane
     (`F1_C2CB`/`F2_C2CB`).
   - Recover a broken link with the protected reprogramming procedure.
   - Change both FPGAs together in stage 1 (this replaces an FPGA1-first plan),
     then free lane B in stage 2.

   Facts:
   - `bd/AXI_Cores/AXI_IP_C2C/AXI_IP_C2C.tcl` sets `C_INCLUDE_AXILITE = 2` on
     every CM core, so `F1_C2C/m_axi_lite` and `F2_C2C/m_axi_lite` already exist,
     clocked but unconnected. Adding `addr_lite` connects them to
     `CM_INTERCONNECT` through `CONNECT_AXI_MASTER_TO_INTERCONNECT` (type
     `AXI4Lite`), exactly as for `F1_C2CB`/`F2_C2CB` today, without changing the
     core configuration.
   - In the EMP builds every CM AXI reset, including both slave cores, comes from
     `SYS_RESET`, whose only input is `locked_clk200` (the emp-fwk `c2c_infra`
     MMCM, whose reset is tied low). Reconfiguring the FPGA is the only reset of
     the slave core.

   - [ ] Stage 1 (both FPGAs)
     - [x] `src/CM_yaml/CM_C2C/Cornell_rev2_p1_C2C_8g.yaml`: add
       `addr_lite: ${::AXI_BUS_CTRL}` to `F1_C2C`. The file is included by
       `Cornell_rev2_p1_VU13p-1-SM_USP`, `EMP_Cornell_rev2_p1_VU13p-1-SM_USP`,
       `EMP_Cornell_rev2_p1_VU13p-2-SM_USP` and `EMP_Cornell_rev3_p1_VU13p-1-SM_USP`.
     - [x] `src/CM_yaml/CM_C2C/Cornell_rev2_p2_C2C_8g.yaml`: add
       `addr_lite: ${::AXI_BUS_CTRL}` to `F2_C2C`. The file is included by
       `Cornell_rev2_p2_VU13p-1-SM_USP`, `EMP_Cornell_rev2_p2_VU13p-1-SM_USP`,
       `EMP_Cornell_rev2_p2_VU13p-2-SM_USP` and `EMP_Cornell_rev3_p2_VU13p-1-SM_USP`.
     - [x] Keep `F1_C2CB` and `F2_C2CB` connected, so these images also work with
       SM images that still use lane B; they carry no traffic once the SM moves the
       windows. Keep each FPGA's PicoBlaze UART interrupt (both YAMLs name the UART
       `CM1_PB_UART`) on its `F*_C2CB/axi_c2c_s2m_intr_in`, so the interrupt index
       on the SM is unchanged.
     - [x] No HDL change: the new connections are inside the block design, so the
       wrapper ports, `sub_module.vhd` and `top.vhd` are unchanged.
     - [ ] Build: the block designs validate; `CM_INTERCONNECT` gains one
       AXI4-Lite slave port (in the EMP builds its masters become JTAG-to-AXI,
       `F*_C2C` AXI4, `F*_C2C` AXI4-Lite and `F*_C2CB` AXI4-Lite); the `F*_C2C`
       and `F*_C2CB` configuration summaries are unchanged; timing passes.
     - [ ] Point the EMP build's CM_FPGA_FW checkout (ipbb, through emp-fwk
       `cm.dep`) at this branch for the test images.
     - [ ] Deploy these CM images on both FPGAs before the stage-1 SM image. Check
       register access first with the old SM image (lane B), then with the
       stage-1 SM image (lane A). Then run the SM SPEC bring-up, soak and recovery
       checks.
   - [ ] Stage 2 (free lane B, once it has a new use)
     - [ ] Remove `F1_C2CB`/`F2_C2CB`. Move each PicoBlaze UART interrupt to
       `F1_C2C`/`F2_C2C` (`axi_c2c_s2m_intr_in`) and set the `interrupts` value in
       its `dt_data` to the new SM interrupt index.
     - [ ] `sub_module.vhd`/`top.vhd`: remove the `F*_C2CB_*` port maps, tie off
       `C2C_Mon.C2C(2)`, and retire `C2C_INTF` lane 2 (PicoBlaze link 2) or reuse
       it for the new lane.
     - [ ] The lane-2 transceiver pins are top-level ports in emp-fwk
       (`c2c_infra.vhd`) and cannot be left unconnected: connect the lane's new
       user in the same change, or remove the ports and constraints in emp-fwk.
     - [ ] Update the address tables and status tables for lane 2.
