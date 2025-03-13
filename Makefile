all: sd_card_tb

.PHONY: vvp waveform clean

sd_card_tb: src/sd_clk_gen.sv tb/sd_card_tb.sv
	iverilog -g2012 -o sd_card_tb src/sd_clk_gen.sv src/sd_spi_output_init.sv src/sd_card_state.sv tb/sd_card_tb.sv

sd_card_tb.vcd: sd_card_tb
	vvp sd_card_tb

vvp: sd_card_tb.vcd

waveform: sd_card_tb.vcd
	GDK_BACKEND=x11 gtkwave sd_card_tb.vcd & disown


clean:
	rm -f sd_card_tb sd_card_tb.vcd
