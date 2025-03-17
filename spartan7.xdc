## Clock Signal
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sysclk [get_ports clk]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clk]

create_generated_clock -source [get_ports clk] -divide_by 128 [get_pins sd_clock/out[0]]

## Buttons
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports rst]


## LEDS
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports led1]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports led2]

## SDCARD
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports sd_cs]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports sd_clk]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports sd_data_in]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports sd_data_out]



## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
