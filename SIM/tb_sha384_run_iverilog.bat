del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_sha384.sv  ../RTL/sha384.sv
vvp -n sim.out
del sim.out
pause