# SPEC

## Current status (c2c_dma_jrf_128_to_64)

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
1. [x] CM_FPGA_FW: Establish 64-bit AXI @ 100 MHz with 8 Gb/s C2C PHY for Rev2 EMP bandwidth tests

   - [ ] Baseline
     - [ ] Current far-end FPGA (CM_FPGA_FW):
       - AXI fabric @ 50 MHz
       - AXI data width = 64-bit
       - Aurora link configured for ~5 Gbps operation
       - C2C1 / C2C2 operating in Compact 2-1 mode
     - [ ] Designed to match previous 64-bit @ 50 MHz system

   - [ ] Objective
     - [ ] Upgrade far-end design to match new near-end gearbox architecture:
       - Maintain 64-bit AXI width on the full AXI C2C path
       - Increase AXI clock to 100 MHz for EMP builds
       - Use 8 Gb/s Aurora with CPLL to avoid GTYE4_COMMON/QPLL placement coupling
       - Preserve a separate 32-bit AXI-Lite C2CB path

   - [x] Aurora PHY Upgrade
     - [x] Reconfigure Aurora cores to:
       - Line rate: 8 Gbps
       - PLL: CPLL
       - Lanes: 1
       - Maintain Compact 2-1 mode
     - [x] Use 200 MHz reference clock in the C2C YAML.
     - [x] Add P2 GT placement/pre-place handling for the C2C channel.

   - [x] AXI Clock Upgrade (Global)
     - [x] Replace 50 MHz AXI clock with 100 MHz across EMP base AXI infrastructure:
       - AXI Interconnect
       - All AXI slaves
       - C2C1 / C2C2 interfaces
       - AXI Protocol Firewalls
     - [x] Set `AXI_MASTER` to 100000000 in `src/CM_yaml/EMP_base.yaml`.

   - [ ] Reset Strategy (100 MHz domain)
     - [ ] Add Processor System Reset:
       - `slowest_sync_clk` → 100 MHz
       - `ext_reset_in` → existing external reset
       - `dcm_locked` → Clocking Wizard `locked`
     - [ ] Use `peripheral_aresetn` for all AXI logic

   - [x] AXI Infrastructure Update
     - [ ] Ensure all AXI paths remain:
       - 64-bit width
       - 100 MHz capable
     - [ ] Validate:
       - AXI Interconnect timing at 100 MHz
       - No implicit 50 MHz constraints remain
     - [x] Add 8 MiB IPbus windows and 1 MiB scratch BRAM endpoints for Rev2 EMP p1/p2 testing.

   - [x] Endpoint Throughput Validation
     - [x] Verify bandwidth against scratch BRAM / native AXI test path:
       - IPbus-to-BRAM: ~380 Mbps
       - Native AXI writes: ~700 Mbps
     - [ ] Check:
       - BRAM / URAM interfaces
       - DMA endpoints (if present)
       - Register blocks (ensure no unintended throttling)
     - [ ] Identify any slow peripherals and isolate if needed

   - [x] C2C Interface Alignment
     - [x] Ensure C2C1 / C2C2 full AXI path:
       - AXI clock = 100 MHz
       - AXI width = 64-bit
       - Aurora line rate = 8 Gb/s
       - CPLL selected
     - [x] Keep AXI-Lite links (C2C1B / C2C2B) at 32-bit width.

   - [ ] Clock Domain Consistency
     - [ ] Ensure:
       - Single AXI clock domain at 100 MHz
       - No unintended crossings back to 50 MHz
     - [ ] Remove or update legacy 50 MHz AXI domains

   - [ ] Validation
     - [ ] Verify clocks:
       - 100 MHz present and stable
     - [ ] Verify AXI:
       - No protocol violations
       - No timing failures
     - [x] Verify Aurora:
       - Link up at 8 Gb/s
       - 1-lane CPLL configuration
     - [ ] End-to-end:
       - Sustained throughput matches expected bandwidth

   - [ ] Do NOT Modify
     - [ ] AXI data width (must remain 64-bit)
     - [ ] Functional behavior of endpoints
     - [ ] Protocol-level behavior of C2C

   - [ ] Intent
     - [ ] Align far-end FPGA with near-end gearbox architecture
     - [ ] Remove bandwidth bottleneck caused by 50 MHz AXI domain
     - [x] Move to the stable 8 Gb/s CPLL configuration used for the best measured bandwidth build

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