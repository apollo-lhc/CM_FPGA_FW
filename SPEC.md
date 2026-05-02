# SPEC

## Current status (validated on hardware)

C2C / AXI-C2C datapath (`axi_chip2chip` + external `aurora_64b66b`):
- Known-good 1-lane AXI4 configuration uses `CONFIG.C_INTERFACE_MODE = 1` (“Compact 2-1”); `CONFIG.C_AURORA_WIDTH` is derived/locked.
- Link handler enabled (`CONFIG.C_EN_AXI_LINK_HNDLR = true`).

Measured on blade with the 64-bit AXI build:
- IPbus-to-BRAM sustained throughput: ~380 Mbps (previously ~160 Mbps write-only).
- Native AXI write sustained throughput: ~700 Mbps.

## Work items
1. [ ] CM_FPGA_FW: Upgrade AXI + Aurora link to support 64-bit @100MHz (10 Gbps PHY)

   - [ ] Baseline
     - [ ] Current far-end FPGA (CM_FPGA_FW):
       - AXI fabric @ 50 MHz
       - AXI data width = 64-bit
       - Aurora link configured for ~5 Gbps operation
       - C2C1 / C2C2 operating in Compact 2-1 mode
     - [ ] Designed to match previous 64-bit @ 50 MHz system

   - [ ] Objective
     - [ ] Upgrade far-end design to match new near-end gearbox architecture:
       - Maintain 64-bit AXI width throughout
       - Increase AXI clock to ≥ 100 MHz across entire design
       - Support sustained throughput equivalent to 10 Gbps Aurora link
       - Ensure compatibility with updated C2C1 / C2C2 configuration

   - [x] Aurora PHY Upgrade
     - [x] Reconfigure Aurora cores to:
       - Line rate: 10 Gbps
       - Maintain Compact 2-1 mode
     - [ ] Verify:
       - Reference clock supports required line rate
       - GT configuration matches near-end FPGA
       - Lane configuration consistent with near-end (1 or 2 lanes as required)

   - [ ] AXI Clock Upgrade (Global)
     - [ ] Replace 50 MHz AXI clock with 100 MHz across:
       - AXI Interconnect
       - All AXI slaves
       - C2C1 / C2C2 interfaces
       - AXI Protocol Firewalls
     - [ ] Use Clocking Wizard:
       - Input: existing clock source
       - Output: 100 MHz AXI clock
       - Use `locked` signal

   - [ ] Reset Strategy (100 MHz domain)
     - [ ] Add Processor System Reset:
       - `slowest_sync_clk` → 100 MHz
       - `ext_reset_in` → existing external reset
       - `dcm_locked` → Clocking Wizard `locked`
     - [ ] Use `peripheral_aresetn` for all AXI logic

   - [ ] AXI Infrastructure Update
     - [ ] Ensure all AXI paths remain:
       - 64-bit width
       - ≥ 100 MHz capable
     - [ ] Validate:
       - AXI Interconnect timing at 100 MHz
       - No implicit 50 MHz constraints remain

   - [ ] Endpoint Throughput Validation
     - [ ] Verify all AXI slaves can sustain:
       - 64-bit @ 100 MHz
     - [ ] Check:
       - BRAM / URAM interfaces
       - DMA endpoints (if present)
       - Register blocks (ensure no unintended throttling)
     - [ ] Identify any slow peripherals and isolate if needed

   - [ ] C2C Interface Alignment
     - [ ] Ensure C2C1 / C2C2:
       - AXI clock = 100 MHz
       - AXI width = 64-bit
       - Configuration matches near-end FPGA
     - [ ] Do NOT modify:
       - AXI-Lite links (C2C1B / C2C2B) unless required

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
     - [ ] Verify Aurora:
       - Link up at 10 Gbps
       - No lane mismatch with near-end
     - [ ] End-to-end:
       - Sustained throughput matches expected bandwidth

   - [ ] Do NOT Modify
     - [ ] AXI data width (must remain 64-bit)
     - [ ] Functional behavior of endpoints
     - [ ] Protocol-level behavior of C2C

   - [ ] Intent
     - [ ] Align far-end FPGA with near-end gearbox architecture
     - [ ] Remove bandwidth bottleneck caused by 50 MHz AXI domain
     - [ ] Enable full utilization of 10 Gbps Aurora link

   - [ ] Deliverables
     - [ ] Updated YAML block design description
     - [ ] Updated Python generation scripts
     - [ ] Updated TCL:
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