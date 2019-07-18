set build_target=processor_tb
set build_dependencies=alu.vhd memory.vhd processor.vhd processor_tb.vhd registers.vhd
set build_options=--ieee=synopsys -fexplicit
set simulation_options=--assert-level=none --ieee-asserts=disable-at-0 --stop-time=1ms
ghdl --clean
ghdl -a %build_options% %build_dependencies%
ghdl -e %build_options% %build_target% 
ghdl -r %build_options% %build_target% %simulation_options% --vcd=%build_target%.vcd
