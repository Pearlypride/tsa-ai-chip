#!/usr/bin/env bash
set -e

cd ~/tsa-ai-chip

echo "[1/3] Compiling TSA-1 4x4 systolic core..."

iverilog -g2012 -o build/tsa_systolic_4x4_core_i8_sim \
rtl/tsa_pe_i8.v \
rtl/tsa_systolic_4x4_i8.sv \
rtl/tsa_systolic_4x4_core_i8.sv \
tb/tsa_systolic_4x4_core_i8_tb.sv

echo "[2/3] Running simulation..."

vvp build/tsa_systolic_4x4_core_i8_sim

echo "[3/3] Opening GTKWave with preset signals..."

gtkwave waves/tsa_systolic_4x4_core_i8.vcd waves/tsa_systolic_4x4_core_i8.gtkw &

sleep 1.5

# Try to focus GTKWave and press Zoom Fit.
# In most GTKWave builds, Ctrl+Alt+F does zoom full/fit.
xdotool search --name "GTKWave" windowactivate --sync key ctrl+alt+f || true

wait
