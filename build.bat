set build_target = "processor_tb"
set build_dependencies = "alu.vhd memory.vhd processor.vhd processor_tb.vhd registers.vhd"
set build_options = "--ieee=synopsys -fexplicit"
set simulation_options = "--assert-level=none --ieee-asserts=disable-at-0 --stop-time=1ms"
ghdl --clean
ghdl -a --ieee=synopsys -fexplicit alu.vhd memory.vhd processor.vhd processor_tb.vhd registers.vhd unidad_forwarding.vhd
ghdl -e --ieee=synopsys -fexplicit processor_tb
ghdl -r --ieee=synopsys -fexplicit processor_tb --assert-level=none --ieee-asserts=disable-at-0 --stop-time=1ms --vcd=processor_tb.vcd
