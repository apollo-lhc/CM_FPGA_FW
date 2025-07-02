#!/bin/bash

set -e

echo "Starting target build script..."

if [[ -z "${CM_FPGA_FW_TARGET_LIST:-}" ]]; then
  echo "No specific targets provided, building all default targets..."
  TARGETS=("EMP_Cornell_rev2_p1_VU13p-1-SM_USP" "EMP_Cornell_rev2_p2_VU13p-1-SM_USP" "EMP_Cornell_rev3_p1_VU13p-1-SM_USP" "EMP_Cornell_rev3_p2_VU13p-1-SM_USP")
else
  IFS=',' read -ra TARGETS <<< "$CM_FPGA_FW_TARGET_LIST"
fi

for target in "${TARGETS[@]}"; do
  echo "Building target: $target"
  make prebuild_"$target"
  make address_table_"$target"
done