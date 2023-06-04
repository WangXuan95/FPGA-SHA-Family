del sim.out dump.vcd
iverilog  -g2001  -o sim.out  tb_sha.v  ../RTL/sha1.v  ../RTL/sha224.v  ../RTL/sha256.v  ../RTL/sha384.v  ../RTL/sha512.v
vvp -n sim.out
del sim.out
pause