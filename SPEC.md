# SPEC

## Current status (baseline inherited from c2c_dma_jrf_128_to_64)

This branch is the known-good 8 Gb/s C2C bandwidth-test branch for the EMP Cornell Rev2 CM builds. It keeps the full AXI C2C datapath at 64-bit width, moves the shared EMP AXI master clock to 100 MHz, and uses one Aurora lane per C2C link with per-channel CPLL clocking.

C2C / AXI-C2C datapath (`axi_chip2chip` + external `aurora_64b66b`):
- 1-lane AXI4 C2C links use `speed: 8`, `gt_pll: cpll`, `refclk_freq: 200`, and `primary_serdes: 1`.
- Full AXI C2C links use `axi_data_width: 64`.
- AXI-Lite C2CB links use `axi_data_width: 32` and remain separate from the full AXI path.
- Known-good configuration uses Compact 2-1 mode from the generated AXI C2C IP; `CONFIG.C_AURORA_WIDTH` is derived/locked.
- Link handler enabled (`CONFIG.C_EN_AXI_LINK_HNDLR = true`).

Measured on blade with the 64-bit AXI build from this branch:
- IPbus-to-BRAM sustained throughput: ~380 Mbps (previously ~160 Mbps write-only).
- Native AXI write sustained throughput: ~700 Mbps.

Primary branch wiring:
- `EMP_Cornell_rev2_p1_VU13p-1-SM_USP` includes `src/CM_yaml/CM_C2C/Cornell_rev2_p1_C2C_8g.yaml`.
- `EMP_Cornell_rev2_p2_VU13p-1-SM_USP` includes `src/CM_yaml/CM_C2C/Cornell_rev2_p2_C2C_8g_autoplace.yaml`.
- The EMP base AXI master clock is 100 MHz.
- F1/F2 IPbus windows are 8 MiB on the full AXI endpoint path.
- F1/F2 scratch RAM windows are 1 MiB, 64-bit BRAM-backed AXI4 endpoints for raw AXI and DMA-over-C2C testing.

## Work items
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
     - [ ] Verify:
       - GT configuration matches near-end FPGA
       - Lane configuration consistent with near-end (1 or 2 lanes as required)

   - [ ] Clocking (AXI4 split domains)
     - [ ] Add Clocking Wizard to generate AXI-C2C clock:
       - Output: 200 MHz (AXI-C2C AXI4 clock)
       - Use `locked` for reset sequencing
     - [ ] Keep existing AXI fabric clock at 100 MHz for local AXI4 interconnect and slaves
     - [ ] Ensure AXI4-only clock domain crossings are explicit (AXI Clock Converter)

   - [ ] Reset Strategy (AXI4 domains)
     - [ ] Add/reset a Processor System Reset for 200 MHz AXI-C2C domain:
       - `slowest_sync_clk` → 200 MHz
       - `ext_reset_in` → existing external reset
       - `dcm_locked` → Clocking Wizard `locked`
       - Use `peripheral_aresetn` for AXI-C2C + converters in the 200 MHz domain
     - [ ] Keep/confirm reset generation for 100 MHz AXI fabric domain

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
     - [ ] Verify Aurora:
       - Link up at 8 Gbps
       - No lane mismatch with near-end
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