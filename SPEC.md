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

## Release candidate v4.1.0 (in preparation; updated 2026-11-11)

Not merged or tagged. Nothing in this section is a hardware result for the release candidates: they are not built yet.

### Compatibility reference: SM_ZYNQ_FW v2.3.0

- **SM_ZYNQ_FW v2.3.0** = `1b3cc542804546bc200244af22f44a1ab73a3216` (2026-10-21, on `develop` and `master`; the
  newest SM tag). Its pins: `bd` `db9af5f`, `build-scripts` `b4c8d4d`, `regmap_helper` `83c6f4b` (with `axiReg`
  `eaa6c5b`), `src/misc` `47e307e`. Since `473b251` the CM pins the same commits.
- It moves each FPGA's register windows to lane A (`0xB1000000`, `0xB3000000`) in its 8 Gb/s gearbox C2C config,
  so it needs this release (work item 3).
- **CM v4.0.0 with SM v2.3.0 is incompatible.** Register access over lane A times out and the AXI-Lite firewall
  latches. This is predicted by the compatibility table (SM_ZYNQ_FW `doc/c2c_axi_dma_1.7_validation.md`,
  section 6), not tested directly.
- No SM change is needed for this release, and none was found to be required.

### Scope, version and candidate commit

Commits on `feature/c2c_axilite_lane_merge` since `master` (`v4.0.0`, `f74b935`):

| Commit | Change | Tested |
|---|---|---|
| `6e3fb88` | `C2C_INTF` and its PicoBlaze at the configured AXI clock, in the six EMP VU13P configs (work item 4) | on hardware, in the experimental images |
| `945951f` | Stage 1 of the lane merge: AXI-Lite on the AXI4 lane, in the 8 Gb/s configs (work item 3) | on hardware, in the experimental images |
| `81dc76a` | `C2C_REFCLK_FREQ` reported in the register map (cherry-picked from `7a57422`; work item 4) | NVC analysis only |
| `a401d51` | The `6e3fb88` fix for the configs it missed (work item 4) | none: those configs do not build from this tree |
| `2c3ba36` | `SPEC.md` record (the previous candidate) | |
| `a7b5988` | `SPEC.md` record | |
| `473b251` | `bd`, `regmap_helper` (with `axiReg`) and `src/misc` moved to SM_ZYNQ_FW v2.3.0's pins | to build (below) |

- **Version: v4.1.0 stands.**
  - The release adds a compatible feature: lane A carries the register traffic, and lane B stays connected for
    older SM images.
  - It also fixes the `C2C_INTF` clock and makes `C2C_REFCLK_FREQ` read a measured value.
  - The register map gains no node (`C2C_REFCLK_FREQ` was already in `C2C_INTFS_CornellRev2.xml`).
  - The shared dependency pins move to SM v2.3.0's (`473b251`, below). No firmware change is expected from that.
- **The candidate is `473b251f40136a68bbc3d12166fc17c9131332ac`** (pushed), so the images' `F*_CM_FW_INFO.GIT_HASH_1`
  reads `0x131332AC`.
  - It replaces `2c3ba36` (`0x3937E363`), so that both repositories are built against the same dependencies.
  - Tag `v4.1.0` on this exact commit, the one the images are built from, so that the identity names the tag.
  - Later `SPEC.md` commits, such as this record, change no firmware and go on top of it.

### The deployable images: EMP application builds

CM_FPGA_FW is the infrastructure; a deployable image is an EMP application build. For this release the
acceptance images are the IT-DTC block-RAM IPbus test builds for the **Cornell rev2 CM** (apollo212-1's CM,
SM_ZYNQ_FW `doc/c2c_axi_dma_1.7_validation.md`, section 5), both FPGAs:

| FPGA | IT-DTC CI config | dep file | CM_FPGA_FW target |
|---|---|---|---|
| 1 | `v2-fpga-1-bram-test` | `top_v2_p1_bramtest.dep` | `EMP_Cornell_rev2_p1_VU13p-1-SM_USP` |
| 2 | `v2-fpga-2-bram-test` | `top_v2_p2_bramtest.dep` | `EMP_Cornell_rev2_p2_VU13p-1-SM_USP` |

- **Confirm the CM revision before building.** The validation record says Cornell rev2. But a note from the
  experimental build (2026-10-12) names `top_v3_p1_bramtest.dep` (IT-DTC `8a141c65`) for the FPGA1 test image, so
  which dep that image used is unresolved. The release images must use the board's own revision: the `v3` deps and
  `EMP_Cornell_rev3_*` targets if it is rev3, and those have no CI config yet.
- **The build branch:** IT-DTC `feature/new_block_ram_jrf_temp`, `8f748e1c` (pushed). It pins CM_FPGA_FW
  `473b251`; its parent `e390e4b9` pinned `2c3ba36`.
- **The build:** IT-DTC CI on emp-pipeline, Vivado 2023.2, part `xcvu13p-flga2577-1-e`. Both configs are manual jobs.
- **The IPbus clock is not part of this release.** CM_FPGA_FW sets no IPbus clock; it uses the one emp-fwk
  provides. Each application chooses its emp-fwk, and with it the clock. The test builds use the emp-fwk their
  application pins (`dc9e6763`, as the experimental images did); record it with the results as part of the test
  configuration. IPbus throughput follows that choice and is not an acceptance criterion for CM_FPGA_FW.
- **Production payloads** (the DTC application builds) are not part of this release. Each is rebuilt against
  v4.1.0 by its own release.

### Experimental images (tested) and release candidates (not yet built)

| | Experimental images | Release candidates |
|---|---|---|
| CM_FPGA_FW | `945951f` (`GIT_HASH_1` `0x0C8FC832`), without `81dc76a` and `a401d51` | `473b251` (`0x131332AC`) |
| emp-fwk (the application's pin) | `dc9e6763` | `dc9e6763` (IT-DTC `8f748e1c`) |
| Packages | FPGA1: `it_dtc_bram_8G_IPBUS_CLOCK_62_5_MHz_FIX_CLK_MON_MERGE.tgz`; FPGA2: its stage-1 counterpart | to be built (above) |
| Hardware | 2026-10-15 to 21 with SM_ZYNQ_FW `75f66d4` to v2.3.0: lane-A register access, console, IPbus integrity on both FPGAs, a one-hour soak, link loss under traffic, the v2.3.0 release tests (work item 3) | none yet |

The experimental results show that the design works. They do not validate the release images.

### Dependencies (audit 2026-10-29; pins aligned with SM v2.3.0 in `473b251`, 2026-11-11)

| Dependency | CM v4.1.0 pin (`473b251`) | SM v2.3.0 pin | CM v4.0.0 and `2c3ba36` pin | Where the v4.1.0 pin is | Open MR |
|---|---|---|---|---|---|
| `bd` (bu_build) | `db9af5f` (v3.0.0-106) | `db9af5f` | `da8c683` (v3.0.0-100) | Only `feature/axi_dma_upgrade` (its tip). `develop` (`2a12a67`, 2023, the default) is an ancestor, 90 commits behind | !1 (draft): `feature/c2c-soft-reset` → `develop`, three of the six commits after `da8c683` |
| `build-scripts` | `b4c8d4d` (v1.1.0-18) | `b4c8d4d` | `b4c8d4d` | Only `c2c_dma_jrf_buildscripts_Unified` (its tip). Fast-forward from both `master` and `develop` | !19: that branch → `master` |
| `regmap_helper` (uhal_axi_regmap) | `83c6f4b` (v3.0.0-1) | `83c6f4b` | `aa6ec79` (v3.0.0-7) | `master` (its tip). The GitLab default branch is `L0MDT_2024_11_27` (tip `48262eb`, 2023), which does not hold it; `develop` lacks 1 commit of it | none |
| `regmap_helper/axiReg` (axi-vhdl-package, nested) | `eaa6c5b` (v1.0.0-1) | `eaa6c5b` | `3b5c5d3` (v1.0.0-2) | `master` (its tip). `develop`, the default, lacks 1 commit of it | none |
| `src/misc` (misc-vhdl) | `47e307e` (v1.0.0-11) | `47e307e` | `60eb0d0` (v1.0.0-2) | `develop` (its tip, the default) | none |
| `bd/utils/buddyallocation` (nested) | `d3ea718` | `d3ea718` | `d3ea718` | `develop` | |
| `FPGA_heater` | `04e423d` | | `04e423d` | `master` | |

- **What `473b251` changes, and why no firmware change is expected:**
  - `bd` gains six commits made for the SM: an optional `gearbox_aux_reset` (the default keeps the old path), the
    C2C recovery and program-control IP helpers, the C2C AXI DMA implementor, and a CI fix. They add procs only,
    and the CM's YAML calls none of them.
  - `regmap_helper` and `axiReg` drop the `128_bit_dma_jrf` extras: node-span tracking (never written to the
    output), `"auto"` addresses, and an `INCLUDE_ILA` option (default false; only debug-state decoding and an ILA).
    The CM uses none of them, and the 128-bit AXI content is the same.
  - `src/misc`: both pins carry the same `slv_128_t`. `47e307e` adds files and types the CM does not name, and a
    `rate_update` output on `rate_counter`, which the existing instances leave open.
  - Checked by reading the code and searching the tree, not by a build: the release build is the test.
- **Every pin is on a public remote branch** (checked 2026-11-11 against the fetched remotes). The 2026-10-29
  clean recursive clone was of `2c3ba36`. Builds resolve submodules with `git submodule update --init --recursive`
  (`make init`; `ipbb add git -r` in the IT-DTC CI), so the `.gitmodules` branch fields do not affect them.
- **`bd` and `build-scripts` still depend on feature branches staying,** for both repositories, until the
  dependency releases below.
- **CM v4.0.0 still pins the `128_bit_dma_jrf` commits** of uhal_axi_regmap, axi-vhdl-package and misc-vhdl. Those
  branches must stay.

Recommended dependency releases, independent of the CM tag:

| Repository | Action | Proposed tag | Why this version |
|---|---|---|---|
| bu_build | Fast-forward `develop` to `db9af5f` (`feature/axi_dma_upgrade`); close or supersede draft !1, which is a subset | `v3.1.0` on `db9af5f` | 106 commits after v3.0.0. They are additive YAML options (128-bit C2C/BRAM, AXIS width converter, interconnect knobs that default to the previous behaviour, `93f88d4`, gearbox aux reset, C2C recovery helpers, the SM DMA implementor). One behavioural change for C2C users, `b4e19fc` (no extra Aurora reset), is validated in both releases. Its other users should know of it, or call it v4.0.0 if they treat it as breaking. The tag is SM v2.3.0's pin exactly, and the CM's pin is in its history |
| build-scripts | Merge !19 as a fast-forward of `master` and `develop` to `b4c8d4d` | `v1.2.0` on `b4c8d4d` | 18 commits after v1.1.0, the build changes for the wide AXI/C2C work. It is both releases' pin exactly |
| uhal_axi_regmap, axi-vhdl-package, misc-vhdl | Protect (or tag) the `128_bit_dma_jrf` branches, which CM v4.0.0 pins. v4.1.0's pins are already on `master`, `master` and `develop` | optional: tags on `83c6f4b` and `eaa6c5b`, which are on `master` but not on the default branch | So that v4.0.0 and v4.1.0 both stay reproducible |

### Release-candidate checks (with SM_ZYNQ_FW v2.3.0; programming needs the developer's approval)

Prerequisites:
- apollo212-1 with the SM v2.3.0 image;
- a SoC OS with the corrected UIODaemon window allocation (SM_ZYNQ_FW `doc/c2c_axi_dma_1.7_validation.md`,
  section 6), since both FPGAs will be loaded;
- the two candidate packages;
- the monitoring services stopped for programming.

The steps for FPGA1 (FPGA2: `-fpga 2`, `F2_*`, `C2C2`, window `0xB3000000`, `-f 2`):

| # | Check | Command (BUTool unless shown) | Expected |
|---|---|---|---|
| 1 | Programming | shell: `uio_send.py program-fpga -fpga 1 -f <FPGA1 candidate package>` | success; `read CM.C2C1_PROGRAM.STATUS` `0x3C01` |
| 2 | Identity | `read F1_CM_FW_INFO.GIT_HASH_1` | `0x131332AC`; the package's address table is from the same build |
| 3 | Register access over lane A | `status 2 C2C`; `read F1_IO.CLK_200_LOCKED` | the reads answer (through `0xB1000000`); `1` |
| 4 | PicoBlaze console | shell: `python3 ~/pbuart.py send version` | answered, readable at 115200 Bd |
| 5 | Clocks | `read F1_C2C_INTF.C2C_1.USER_FREQ`; `read F1_C2C_INTF.C2C_REFCLK_FREQ` | about 125,000,000 (8 Gb/s ÷ 64); about 200,000,000, steady |
| 6 | Verified DMA | shell: `c2c-pages-test resync 1`; `test_stand -c 21 -f 1 -n 0x83000000 -k 1024 -l 0 --verify --duration 60` | 0 words wrong, no timeout or desync |

Then, with both FPGAs loaded:

| # | Check | How | Expected |
|---|---|---|---|
| 7 | Both at once, with monitoring | `BUMonitor` running; step 6 on both FPGAs together for 10 minutes | 0 words wrong on each |
| 8 | Register windows | `read CM.C2C1_PROGRAM.STATUS` and `CM.C2C2_PROGRAM.STATUS` | `0x3C01`: they match the hardware, so there is no window overlap |
| 9 | Older SM (lane B), optional | SM v2.2.0 image, steps 2-5 | Holds by design. Untested unless run, and recorded so |

Afterwards:
- Record each candidate's timing (WNS, WHS, routing complete) from the CI jobs, with the package names and SHA-256.
- Results go in this section.

### Release order

1. **Run the two manual jobs** on IT-DTC `feature/new_block_ram_jrf_temp` (`8f748e1c`, already pushed).
2. **Check timing and routing.** Record the packages and checksums.
3. **The hardware checks above.** Programming needs approval.
4. **If they pass:**
   - tag `v4.1.0` (annotated) on `473b251`;
   - open a PR from `feature/c2c_axilite_lane_merge` to `master`, carrying the `SPEC.md` record commits, and merge
     it with a merge commit, so the tagged commit is in `master`'s history.
5. **Dependencies:** the bu_build and build-scripts tags; protection of the three `128_bit_dma_jrf` branches.
   Recommended before the combined Apollo release documentation, but not a condition of the CM tag.
6. **SM_ZYNQ_FW:** no change. v2.3.0 is the reference, and step 5 makes it, and v4.1.0, reproducible from the
   dependencies' main branches as well.

### Compatibility set and rollback

| SM_ZYNQ_FW | CM images | Status |
|---|---|---|
| v2.3.0 | v4.1.0 candidates (`473b251`) | the release pair: to test |
| v2.3.0 | experimental (`945951f`) | tested 2026-10-15 to 21: the rollback images for v2.3.0 |
| v2.2.0 (lane B) | v4.0.0 | the previous release pair: the rollback for the SM |
| v2.2.0 (lane B) | v4.1.0 | by design only; untested |
| v2.3.0 | v4.0.0 | incompatible (above) |

Keep for rollback:
- the experimental FPGA1 and FPGA2 packages;
- the v4.0.0 packages;
- the SM v2.2.0 image.

### Known limitations of v4.1.0

- No multi-day soak.
- Register access while an AXI4 transfer is stalled is untested.
- Of the configs that include the 8 Gb/s YAMLs, only the EMP rev2 builds are built and tested. The `Cornell_rev2_p*`
  non-EMP configs, the `-2` speed grade and `EMP_Cornell_rev3_*` are not built.
- `a401d51` is unbuilt.
- Many historical configs do not build from this tree (work item 4, last note). That is recorded, not repaired.
- Built and tested only in the IT-DTC test application, with the emp-fwk it pins (`dc9e6763`). Other
  applications choose their own emp-fwk and IPbus clock; those combinations are not built here.

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
     - [x] Experimental test images, not the release build:
       - EMP builds for the Cornell rev2 CM, both FPGAs, from `945951f` (`GIT_HASH_1`
         `0x0C8FC832` on each), through the EMP build's CM_FPGA_FW checkout (ipbb,
         through emp-fwk `cm.dep`);
       - they also carry the 62.5 MHz IPbus clock from emp-fwk's IPbus-clock
         experiment branch, which is outside this repository;
       - they predate `81dc76a` and `a401d51`.
     - [x] Deployed with the stage-1 SM image, on apollo212-1:
       - 2026-10-15, FPGA1 (SM_ZYNQ_FW `75f66d4`):
         - register access over lane A, the PicoBlaze console and the protected
           programming procedure work;
         - throughput is unchanged (speedtest
           `results/2026-10-15_apollo212-1_lane-merge/`).
       - 2026-10-19, both FPGAs (SM_ZYNQ_FW `doc/c2c_axi_dma_1.7_validation.md`):
         - IPbus data integrity on each FPGA;
         - traffic on both at once;
         - a one-hour soak with the monitoring service (about 475 GB, 0 errors);
         - link loss under traffic: each FPGA reprogrammed while both carried
           traffic.
       - 2026-10-21: the SM_ZYNQ_FW v2.3.0 release tests, both FPGAs.
     - [ ] Register access with an old SM image (lane B): not tested. It holds by
       design, since lane B stays connected. It stays untested unless the
       release-candidate checks run it.
     - [ ] Not yet tested:
       - a multi-day soak;
       - register access while an AXI4 transfer is stalled;
       - the standard-EMP release candidates ("Release candidate v4.1.0");
       - the other configs that include the 8 Gb/s YAMLs (`Cornell_rev2_p*`,
         the `-2` speed grade, `EMP_Cornell_rev3_*`).

   Which configs the lane merge applies to (audit, 2026-10-22):
   - **Where the SM moves the register windows to lane A.** In SM_ZYNQ_FW that is
     only the 8 Gb/s gearbox C2C config (`config_c2c_usp_8g_gearbox.yaml`, from
     v2.3.0). Its 5, 10, 12.5 and 15 Gb/s and 7-series C2C configs keep lane B.
   - **Every CM config on those 8 Gb/s links has it:** the eight that include
     `Cornell_rev2_p{1,2}_C2C_8g.yaml` (listed above).
   - **Not applicable to the others:**
     - the Tcl-built configs at other link rates (5 Gb/s where stated) or for a
       7-series SM (`Cornell_rev1_*`, `Cornell_rev2_*_SM_7s`,
       `Cornell_rev2_*_heaters_allQuads25G`, `MPI_rev1_*`, `EMP_Cornell_rev1_p2_*`)
       pair with SM configs that still use lane B;
     - `Cornell_rev3_*_heaters_TF` and `EMP_Cornell_rev1_p1_*` already connect
       their single link's `m_axi_lite`;
     - `Cornell_rev3_p{1,2}_VU13p-1-SM_USP` hold file lists and constraints only,
       with no top or YAML;
     - `IT-DTC_p1_VU13p-1` holds only a constraints override
       (`src/gt_quad_l_override.xdc`), not a config of its own.
   - **Scope:** this release keeps the lane merge to the 8 Gb/s configs; it is not
     extended to other link configurations.
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

4. [ ] `C2C_INTF` at the configured AXI clock (PicoBlaze UART, C2C clock monitoring)

   The problem:
   - `abca14a` (2026-04-08) moved the EMP AXI master clock to 100 MHz, but
     `C2C_INTF` and its PicoBlaze (`uC`) assumed 50 MHz.
     - The PicoBlaze UART ran at about 231 kBd against the UART Lite's 115200, so
       its console was garbled.
     - The clock monitors inside `C2C_INTF` counted over the wrong window.
   - Separately, several tops measure the C2C user clock against the 200 MHz clock
     with a 2 000 000-cycle window, so `USER_FREQ` read a hundredth of the rate.

   - [x] `6e3fb88`:
     - `uC` takes `CLKFREQ` and `UART_BAUD_RATE`, and computes its baud divider;
     - `C2C_INTF` passes `CLKFREQ` to it, and uses it for `USER_CLK_FREQ`;
     - the six EMP rev2/rev3 VU13P `sub_module.vhd` pass
       `CLKFREQ => AXI_MASTER_CLK_FREQ`, and use a 200 000 000-cycle window.

     On hardware (2026-10-15, the FPGA1 image from `945951f`) the PicoBlaze console
     is readable.
   - [x] The other configs (audit, 2026-10-22):

     | Config | AXI clock of `C2C_INTF` | `CLKFREQ` | C2C user-clock window |
     |---|---|---|---|
     | `EMP_Cornell_rev2_p{1,2}_VU13p-{1,2}-SM_USP`, `EMP_Cornell_rev3_p{1,2}_VU13p-1-SM_USP` | 100 MHz | `AXI_MASTER_CLK_FREQ` (`6e3fb88`) | 200 MHz (`6e3fb88`) |
     | `EMP_Cornell_rev1_p2_VU7p-1-SM_USP`, and its `_SM_7s`, whose `src` links to it | 100 MHz (`BUFGCE_DIV` of `clk_200`) | `100000000` (`a401d51`) | 200 MHz (`a401d51`) |
     | `Cornell_rev2_p{1,2}_VU13p-1-SM_USP_heaters_allQuads25G` | 50 MHz | the default, 50 MHz: correct | 200 MHz (`a401d51`) |
     | `Cornell_rev3_p{1,2}_VU13p-1-SM_USP_heaters_TF` | no `C2C_INTF` | | 200 MHz (`a401d51`, `top.vhd`; the unused `top_v0.vhd`/`top_1.vhd` are unchanged) |
     | `Cornell_rev2_p{1,2}_VU13p-1-SM_USP` | 50 MHz (`Cornell_base.yaml`) | the default: correct | 200 MHz, already |
     | `Cornell_rev1_*`, `Cornell_rev2_*_SM_7s`, `MPI_rev1_*` | 50 MHz | the default: correct | 50 MHz clock, 50 000 000 cycles, already (`MPI_rev1_*`: none) |

   - [ ] `a401d51` is unbuilt and untested. None of the configs it changes builds
     from this tree as it stands (the note below). It is kept, as a separate
     commit, for consistency.
   - [x] `81dc76a` (cherry-picked from `7a57422`): `C2C_INTF` copies the top
     level's `C2C_REFCLK_FREQ` into its register record.
     - **The defect:** before it, only the per-lane fields were copied, so
       `F*_C2C_INTF.C2C_REFCLK_FREQ` (0x810) read 0 in every config, although nine
       tops measure the reference clock.
     - **Not covered by `6e3fb88`,** which fixed `uC`'s clock and the per-lane
       `USER_CLK_FREQ` window.
     - **Every config that builds** uses `C2C_INTFS_CornellRev2.xml`, whose record
       has the field. The configs that name `C2C_INTFS.xml` do not build anyway
       (the note below).
     - **Checked:**
       - `C2C_Intf.vhd` analyses (NVC) against the generated `C2C_INTF_PKG` of
         `EMP_Cornell_rev2_p1_VU13p-1-SM_USP`, before and after the change;
       - the check used entity-only stubs for `uC` and the register map;
       - a misspelled field fails, as it should.
     - [ ] On hardware: the release-candidate checks.

   Note: configs that do not build from this tree as they stand. They are recorded
   here, not repaired. Whether anyone still builds them elsewhere was not checked.
   - **`src/c2cBD/createC2CSlaveInterconnect.tcl`,** removed in `61b9c92`
     (2023-09-05), is named by `Cornell_rev1_*`, `Cornell_rev2_*_SM_7s`,
     `EMP_Cornell_rev1_p2_*` and `MPI_rev1_*`.
   - **The register map `address_table/modules/C2C_INTFS.xml`,** deleted in
     `f59487f` (2023-08-17), is named by:
     - `Cornell_rev1_p1_KU15p-2-SM_USP`, `Cornell_rev1_p2_VU7p-1-SM_USP`;
     - `Cornell_rev2_p2_VU13p-1-SM_7s`;
     - both `Cornell_rev2_*_heaters_allQuads25G`;
     - `EMP_Cornell_rev1_p1_KU15p-2-SM_USP`, `EMP_Cornell_rev1_p2_VU7p-1-SM_USP`;
     - `MPI_rev1_p1_KU15p-2-SM_USP`;
     - the variants that share their files.

     `Cornell_rev2_p1_VU13p-1-SM_USP_heaters_allQuads25G` also has no
     `createC2CSlaveInterconnect.tcl` of its own, which its `files.tcl` expects.
   - **`Cornell_rev3_p{1,2}_VU13p-1-SM_USP_heaters_TF`:** their `files.tcl` name
     files that were removed or never existed:
     - removed in 2022: `src/CM_FW_info/CM_V_info.vhd` (`0158c72`) and
       `cores/Local_Clocking/Local_Clocking.tcl` (`7ce7b65`);
     - never in this repository: `src/heater/heater.vhd`.

     `p1` also names
     `configs/Cornell_rev2_p1_VU13p-1-SM_7s_IBERT_lpGBT/src/c2cBD/createC2CSlaveInterconnect.tcl`,
     which was never in this repository. `p2` keeps its own
     `src/c2cBD/createC2CSlaveInterconnect.tcl`.
