#Compile the Verilog code:
vlib work
vlog -sv -dpiheader dpiheader.h hello.v
#Compile the DPI code for the Solaris operating system:
gcc -c -g -I//home/amandeep/altera/modelsim_ase/include hello_c.c -lpcap
ld -G -Bsymbolic -o hello_c.so hello_c.o
#Simulate the design:
vsim -c -sv_lib hello_c hello_top
# Loading work.hello_c
# Loading ./hello_c.so
