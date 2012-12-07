This folder contains files neccessary to do simple simulation of Amber system.
In Windows OS use "c.bat" to start compiling project with Icarus Verilog.
Icarus Verilog should be installed first.
File "srclist" contains list of all neccessary Amber Project verilog sources.
Main file for simulation is testbench file "tb.v". It is also in the list of "srclist".
Icarus Verilog will use this list to compile.
Output of compilier is file "qqq" (strange name, isn't it? :-) ).
Then run simulation with command "vvp qqq".
Icarus Verilog will simulate system.
This testbench "tb.v" only uses bootram for CPU start.
Bootram memory content is defined by "hello-world.mem" file.
We get "hello-world.mem" when we compile "sw/hello-world-my" with C compiler.
SDRAM is not used at all.
Stack points at the end of bootram.

Here is log of compilation and simulation:
--------------------------------
c:\Altera\Amber-Marsohod2\hw\marsohod2\my_tb\hello-world>c.bat

c:\Altera\Amber-Marsohod2\hw\marsohod2\my_tb\hello-world>iverilog -o qqq -g2005 -DICARUS=1 -DAMBER_A23_CORE=1 -DNOMEMORY=1 -csrclist -I../../../vlog/system/ -I../../../vlog/amber23/ -I../../../vlog/tb/

c:\Altera\Amber-Marsohod2\hw\marsohod2\my_tb\hello-world>vvp qqq
VCD info: dumpfile out.vcd opened for output.
reseting..
Load boot memory from hello-world.mem
Read in 951 lines
log file tests.log, timeout 0, test name my ARM simulation
go..

Marsohod2: Hello, World!
* 0 *
* 1 *
* 2 *
* 3 *
* 4 *
