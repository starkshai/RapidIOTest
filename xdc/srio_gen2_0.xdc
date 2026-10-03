#-----------------------------------------------------------------------------
#
# File name:    srio_gen2_0.xdc
# Rev:          4.0
# Description:  This module constrains the example design
#
#-----------------------------------------------------------------------------
#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
######################################
#         Core Time Specs            #
######################################

create_clock -period 8 -name sys_clkp -waveform {0 4} [get_ports sys_clkp]
set_case_analysis 0 [list [get_pins -hierarchical *mode_1x]]

############# clock define################################
create_clock -period 5.000 [get_ports clk200m_p]
set_property PACKAGE_PIN AE10 [get_ports clk200m_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk200m_p]
#set_multicycle_path -from [get_pins *cfg_raddr_reg* -hierarchical] -to [get_pins *cfg_reg*rdata_reg* -hierarchical] 3
#set_multicycle_path -from [get_pins *cfg_raddr_reg* -hierarchical] -to [get_pins *cfg_reg*rdata_reg* -hierarchical] 2 -hold

######################################################
##       GT and Pin Locations                        #
## NOTE: These pins were selected for:               #
## XC7KX325T FFG900                                  #
## Pins for any other part/package must be relocated #
######################################################

set_property LOC K2 [get_ports o_gtref_tx_p[0]]
set_property LOC K1 [get_ports o_gtref_tx_n[0]]
set_property LOC K6 [get_ports i_gtref_rx_p[0]]
set_property LOC K5 [get_ports i_gtref_rx_n[0]]
set_property LOC J4 [get_ports o_gtref_tx_p[1]]
set_property LOC J3 [get_ports o_gtref_tx_n[1]]
set_property LOC H6 [get_ports i_gtref_rx_p[1]]
set_property LOC H5 [get_ports i_gtref_rx_n[1]]

set_property LOC G8  [get_ports sys_clkp]
set_property LOC G7  [get_ports sys_clkn]

############## fan define##################
set_property IOSTANDARD LVCMOS25 [get_ports fan_pwm]
set_property PACKAGE_PIN AE26 [get_ports fan_pwm]
##############LED define##################
set_property PACKAGE_PIN A22 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]

set_property PACKAGE_PIN C19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]

set_property PACKAGE_PIN B19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]

set_property PACKAGE_PIN E18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
#############si5338  Setting##################
set_property IOSTANDARD LVCMOS33 [get_ports si5338_scl]
set_property PACKAGE_PIN P23 [get_ports si5338_scl]
set_property IOSTANDARD LVCMOS33 [get_ports si5338_sda]
set_property PACKAGE_PIN N25 [get_ports si5338_sda]
set_property IOSTANDARD LVCMOS33 [get_ports pll_clk1]
set_property PACKAGE_PIN T25 [get_ports pll_clk1]

set_property IOSTANDARD LVCMOS33 [get_ports {tx_disable[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx_disable[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx_disable[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx_disable[0]}]

set_property PACKAGE_PIN T28 [get_ports {tx_disable[0]}]
set_property PACKAGE_PIN T27 [get_ports {tx_disable[1]}]
set_property PACKAGE_PIN U28 [get_ports {tx_disable[2]}]
set_property PACKAGE_PIN U25 [get_ports {tx_disable[3]}]

set_clock_groups -asynchronous -group [get_clocks clk200m_p] -group [get_clocks {clkout1 clkout1_1 clkout2 clkout2_1}]