del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_sha1.sv  ../RTL/sha1.sv
vvp -n sim.out
del sim.out
pause