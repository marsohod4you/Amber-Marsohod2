You need verilator to be installed.
Then build c++/Verilog testbench:
$ make

Then run testbench with command
$ ./obj_dir/Vtb

In few seconds output of testbench is:
----------------------------------------
Instantiating 8 MB SDRAM : 4 banks x 4096 rows x 256 cols x 16 bits
Load boot memory from boot-loader.mem
Read in 2022 lines
log file tests.log, timeout 0, test name my ARM simulation 
Amber Boot Loader v20091124203711
Commands
l                             : Load elf file
b <address>                   : Load binary file to <address>
d <start address> <num bytes> : Dump mem
h                             : Print help message
j <address>                   : Execute loaded elf, jumping to <address>
p <address>                   : Print ascii mem until first 0
r <address>                   : Read mem
s                             : Core status
w <address> <value>           : Write mem
Ready

----------------------------------------
This is serial console output of SoC Amber prepared for marsohod2 FPGA board.
C++ testbench very fast simulates CPU/SDRAM/Serial work!

Bootloader is build from sw/boot-loader-8M then this code is placed into static RAM of Amber SoC.
But anyway system will not work without SDRAM because CPU stack is pointed into SDRAM top during bootloader start.
 