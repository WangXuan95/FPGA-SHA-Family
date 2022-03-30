del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_sha512.sv  ../RTL/sha512.sv
vvp -n sim.out
del sim.out
pause