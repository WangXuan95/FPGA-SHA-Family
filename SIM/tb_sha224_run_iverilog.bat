del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_sha224.sv  ../RTL/sha224.sv
vvp -n sim.out
del sim.out
pause