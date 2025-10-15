GHDL		= ghdl
GHDL_FLAG	= --std=08
STOP_TIME	= 100us
WAVE_NAME	= wave.ghw

WAVE_VIEWER	= gtkwave

SRCS		= $(wildcard */*.vhdl) $(wildcard *.vhdl)
TB_SRCS		= $(subst _tb.vhdl, , $(filter %_tb.vhdl, $(SRCS)))
TB_FILE		= $(filter %$(TB)_tb.vhdl, $(SRCS))
TB_DIR		= $(dir $(TB_FILE))

.PHONY: all clean compile simulate compile-root $(COMPILE_DIRS)

all: clean compile simulate

compile: $(SRCS)
	@echo "Compiling VHDL sources..."
	@$(GHDL) -i $(GHDL_FLAG) $(SRCS)

simulate:
	@if [ -z "$(TB)" ]; then \
		echo "No testbench specified. Use: make simulate TB=name"; exit 1; \
	fi
	@if [ -z "$(TB_FILE)" ]; then \
		echo "Testbench '$(TB)' not found; available: $(notdir $(TB_SRCS))"; exit 1; \
	fi

	@make -s compile
	@echo "Simulating $(TB)"
	@$(GHDL) -m $(GHDL_FLAG) $(TB)_tb
	@$(GHDL) -r $(GHDL_FLAG) $(TB)_tb --stop-time=$(STOP_TIME) --wave=$(TB_DIR)$(WAVE_NAME)
	@echo "Simulation completed. Waveform saved to $(TB_DIR)$(WAVE_NAME)"

view:
	@if [ -z "$(TB)" ]; then \
		echo "No testbench waveform specified. Use: make view TB=name"; exit 1; \
	fi

	@make -s simulate TB=$(TB)
	@echo "Opening waveform viewer for $(TB_DIR)$(WAVE_NAME)..."
	@$(WAVE_VIEWER) $(TB_DIR)$(WAVE_NAME) &

clean:
	@echo "Removing generated files"
	@rm -rf *.cf */*.cf *.ghw */*.ghw
