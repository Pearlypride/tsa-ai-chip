#!/usr/bin/env bash
set -e

cd ~/tsa-ai-chip

mkdir -p build waves reports

echo "[1/4] Compile 4x4 core..."

iverilog -g2012 -o build/tsa_systolic_4x4_core_i8_sim \
rtl/tsa_pe_i8.v \
rtl/tsa_systolic_4x4_i8.sv \
rtl/tsa_systolic_4x4_core_i8.sv \
tb/tsa_systolic_4x4_core_i8_tb.sv

echo "[2/4] Run Verilog simulation..."

vvp build/tsa_systolic_4x4_core_i8_sim

echo "[3/4] Generate visual report..."

python3 scripts/visual_report_4x4.py

echo "[4/4] Open report..."

xdg-open reports/tsa_4x4_report.png >/dev/null 2>&1 || true

echo "Done."
