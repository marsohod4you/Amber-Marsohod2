This folder contains files neccessary to do simple simulation of Amber system.
In Windows OS use "c_sdr.bat" to start compiling project with Icarus Verilog.
Icarus Verilog should be installed first.
File "srclist_sdr" contains list of all neccessary Amber Project verilog sources.
Main file for simulation is testbench file "tb_sdr.v". It is also in the list of "srclist_sdr".
Icarus Verilog will use this list to compile.
Output of compilier is file "qqq" (strange name, isn't it? :-) ).
Then run simulation with command "vvp qqq".
Icarus Verilog will simulate system.
This testbench "tb_sdr.v" only uses bootram for CPU start.
Bootram memory content is defined by "boot-loader.mem" file.
We get "boot-loader.mem" when we compile "sw/boot-loader-8M" with C compiler.
SDRAM is used for tests here.
Stack points at the end of SDRAM.
With that simulation we can see how SDRAM works, how it is initialized and how read/writes occur.

Here is log of simulation:
--------------------------------
c:\Altera\Amber-Marsohod2\hw\marsohod2\my_tb\boot-loader>vvp qqq
VCD info: dumpfile out.vcd opened for output.
reseting..
Load boot memory from boot-loader.mem
Read in 2033 lines
log file tests.log, timeout 0, test name my ARM simulation
go..
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
>
