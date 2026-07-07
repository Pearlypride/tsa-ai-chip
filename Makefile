PROJECT = TSA-1

BUILD_DIR = build
WAVES_DIR = waves
REPORTS_DIR = reports

IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
PYTHON = python3

RTL_4X4 = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_4x4_i8.sv \
	rtl/tsa_systolic_4x4_core_i8.sv

TB_4X4 = tb/tsa_systolic_4x4_core_i8_tb.sv
SIM_4X4 = $(BUILD_DIR)/tsa_systolic_4x4_core_i8_sim

RTL_8X8 = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_8x8_i8.sv \
	rtl/tsa_systolic_8x8_core_i8.sv

TB_8X8 = tb/tsa_systolic_8x8_core_i8_tb.sv
SIM_8X8 = $(BUILD_DIR)/tsa_systolic_8x8_core_i8_sim

RTL_MMIO = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_4x4_i8.sv \
	rtl/tsa_systolic_4x4_core_i8.sv \
	rtl/tsa_fpga_top_mmio_i8.sv

TB_MMIO = tb/tsa_fpga_top_mmio_i8_tb.sv
SIM_MMIO = $(BUILD_DIR)/tsa_fpga_top_mmio_i8_sim

RTL_MEM = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_4x4_i8.sv \
	rtl/tsa_systolic_4x4_core_i8.sv \
	rtl/tsa_fpga_top_mem_i8.sv

TB_MEM = tb/tsa_fpga_top_mem_i8_tb.sv
SIM_MEM = $(BUILD_DIR)/tsa_fpga_top_mem_i8_sim

RTL_AXI = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_4x4_i8.sv \
	rtl/tsa_systolic_4x4_core_i8.sv \
	rtl/tsa_axi_lite_top_i8.sv

TB_AXI = tb/tsa_axi_lite_top_i8_tb.sv
SIM_AXI = $(BUILD_DIR)/tsa_axi_lite_top_i8_sim

RTL_AXI8 = \
	rtl/tsa_pe_i8.v \
	rtl/tsa_systolic_8x8_i8.sv \
	rtl/tsa_systolic_8x8_core_i8.sv \
	rtl/tsa_axi_lite_top_8x8_i8.sv

TB_AXI8 = tb/tsa_axi_lite_top_8x8_i8_tb.sv
SIM_AXI8 = $(BUILD_DIR)/tsa_axi_lite_top_8x8_i8_sim

.PHONY: all dirs test4x4 test8x8 random random8x8 visual report report8x8 timeline mmio mem axi axi8x8 cardtest synth synth-xilinx visual-mmio visual-mem visual-axi visual-axi8x8 clean help

all: mem

dirs:
	mkdir -p $(BUILD_DIR) $(WAVES_DIR) $(REPORTS_DIR)

test4x4: dirs
	$(IVERILOG) -g2012 -o $(SIM_4X4) $(RTL_4X4) $(TB_4X4)
	$(VVP) $(SIM_4X4)

test8x8: dirs
	$(PYTHON) scripts/gen_tsa_systolic.py
	$(IVERILOG) -g2012 -o $(SIM_8X8) $(RTL_8X8) $(TB_8X8)
	$(VVP) $(SIM_8X8)

random: dirs
	$(PYTHON) scripts/random_verify_4x4.py

random8x8: dirs test8x8
	$(PYTHON) scripts/random_verify_8x8.py

report8x8: test8x8
	$(PYTHON) scripts/visual_report_8x8.py
	xdg-open $(REPORTS_DIR)/tsa_8x8_report.png >/dev/null 2>&1 || true

visual: test4x4
	$(GTKWAVE) $(WAVES_DIR)/tsa_systolic_4x4_core_i8.vcd $(WAVES_DIR)/tsa_systolic_4x4_core_i8.gtkw

report: test4x4
	$(PYTHON) scripts/visual_report_4x4.py
	xdg-open $(REPORTS_DIR)/tsa_4x4_report.png >/dev/null 2>&1 || true

timeline: test4x4
	$(PYTHON) scripts/wave_timeline_4x4.py
	xdg-open $(REPORTS_DIR)/tsa_4x4_timeline.png >/dev/null 2>&1 || true

mmio: dirs
	$(IVERILOG) -g2012 -o $(SIM_MMIO) $(RTL_MMIO) $(TB_MMIO)
	$(VVP) $(SIM_MMIO)

mem: dirs
	$(IVERILOG) -g2012 -o $(SIM_MEM) $(RTL_MEM) $(TB_MEM)
	$(VVP) $(SIM_MEM)

cardtest: dirs
	$(PYTHON) scripts/tsa_cardtest.py

axi: dirs
	$(IVERILOG) -g2012 -o $(SIM_AXI) $(RTL_AXI) $(TB_AXI)
	$(VVP) $(SIM_AXI)

visual-axi: axi
	$(GTKWAVE) $(WAVES_DIR)/tsa_axi_lite_top_i8.vcd

axi8x8: dirs test8x8
	$(PYTHON) scripts/gen_tsa_axi8.py
	$(IVERILOG) -g2012 -o $(SIM_AXI8) $(RTL_AXI8) $(TB_AXI8)
	$(VVP) $(SIM_AXI8)

visual-axi8x8: axi8x8
	$(GTKWAVE) $(WAVES_DIR)/tsa_axi_lite_top_8x8_i8.vcd

synth: dirs test8x8 axi8x8
	mkdir -p reports/synth
	yosys -s synth/synth_tsa2_8x8.ys | tee reports/synth/tsa2_8x8_core_yosys.log
	yosys -s synth/synth_tsa2_axi8.ys | tee reports/synth/tsa2_axi8_yosys.log
	@echo "Synthesis logs:"
	@echo "  reports/synth/tsa2_8x8_core_yosys.log"
	@echo "  reports/synth/tsa2_axi8_yosys.log"

visual-mmio: mmio
	$(GTKWAVE) $(WAVES_DIR)/tsa_fpga_top_mmio_i8.vcd

visual-mem: mem
	$(GTKWAVE) $(WAVES_DIR)/tsa_fpga_top_mem_i8.vcd

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf $(WAVES_DIR)/*.vcd
	rm -rf $(REPORTS_DIR)/*.png
	rm -rf $(REPORTS_DIR)/*.csv

help:
	@echo "$(PROJECT) commands:"
	@echo "  make test4x4     - raw 4x4 INT8 systolic core"\n	@echo "  make test8x8     - raw 8x8 INT8 systolic core, 64 PE"\n	@echo "  make random8x8   - 30 random tests for 8x8 core"\n	@echo "  make report8x8   - visual PNG report for 8x8 core"
	@echo "  make random      - 50 random NumPy vs Verilog tests"
	@echo "  make report      - matrix PNG report"
	@echo "  make timeline    - core timeline PNG report"
	@echo "  make mmio        - MMIO register-style top"
	@echo "  make mem         - FPGA-style local memory top"\n	@echo "  make axi         - AXI-Lite compatible accelerator top"\n	@echo "  make axi8x8      - AXI-Lite compatible 8x8 accelerator top"\n	@echo "  make synth       - run Yosys synthesis checks for TSA-2"\n\t@echo "  make synth-xilinx - run Yosys synth_xilinx xc7 estimate"\n	@echo "  make cardtest    - user-friendly full accelerator test"
	@echo "  make visual-mmio - open MMIO waveform"
	@echo "  make visual-mem  - open memory waveform"
	@echo "  make clean       - clean build/waves/reports"

.PHONY: synth-xilinx

synth-xilinx:
	mkdir -p reports/synth
	yosys -s synth/synth_tsa2_axi8_xilinx.ys | tee reports/synth/tsa2_axi8_xilinx_xc7.log
	@echo "Xilinx synthesis log:"
	@echo "  reports/synth/tsa2_axi8_xilinx_xc7.log"
