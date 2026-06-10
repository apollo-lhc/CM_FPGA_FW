# CONTEXT

## Branch: c2c_dma_jrf_128_to_64

This branch is the CM FPGA side of the 64-bit AXI / 8 Gb/s C2C bandwidth-test work. The best observed tarball build from 23 Apr 12:27 maps most closely to commit `e7b4948`; the original branch tip differed from that build anchor by a documentation-only `SPEC.md` update.

## Current technical state

- EMP AXI master infrastructure is configured for 100 MHz in `src/CM_yaml/EMP_base.yaml`.
- Full AXI C2C links use 64-bit AXI data width.
- AXI-Lite C2CB links use 32-bit AXI data width.
- Rev2 EMP C2C links use one Aurora lane at `speed: 8` with `gt_pll: cpll` and 200 MHz reference clock.
- Rev2 p1 includes `src/CM_yaml/CM_C2C/Cornell_rev2_p1_C2C_8g.yaml`.
- Rev2 p2 includes `src/CM_yaml/CM_C2C/Cornell_rev2_p2_C2C_8g_autoplace.yaml`.
- Rev2 EMP p1/p2 IPbus windows are 8 MiB on the full AXI endpoint path.
- Rev2 EMP p1/p2 include 1 MiB, 64-bit scratch BRAM endpoints for raw AXI and DMA-over-C2C testing.

## Measured behavior

Measured on blade with the 64-bit AXI build:

- IPbus-to-BRAM sustained throughput: about 380 Mbps.
- Native AXI write sustained throughput: about 700 Mbps.

## Important notes

- The 8 Gb/s CPLL configuration supersedes earlier 10 Gb/s/QPLL experiments for this branch's known-good bandwidth result.
- The p2 autoplace variant carries GT pre-place/diagnostic handling to keep C2C placement compatible with the TTC/TCDS2 relay GT resources.
- UART/device-tree clock metadata is still parked for later validation; see `SPEC.md` for the checklist.
- `build_targets.sh` defaults to Rev2 p1/p2 `VU13p-1`, Rev2 p1/p2 `VU13p-2`, and Rev3 EMP compatibility targets.
