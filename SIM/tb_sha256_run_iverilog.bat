del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_sha256.sv  ../RTL/sha256.sv
vvp -n sim.out
del sim.out
pause