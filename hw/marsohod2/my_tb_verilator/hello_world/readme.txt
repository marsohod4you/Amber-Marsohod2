You need verilator to be installed.
Then build c++/Verilog testbench:
$ make

Then run testbench with command
$ ./obj_dir/Vtb

In few seconds output of testbench is:
----------------------------------------
Load boot memory from hello-world.mem
Read in 919 lines
log file tests.log, timeout 0, test name my ARM simulation 

Marsohod2: Hello, World!!!!!
*** 0 ***
*** 1 ***
*** 2 ***
*** 3 ***
*** 4 ***
----------------------------------------
This is serial console output of SoC Amber prepared for marsohod2 FPGA board.
C++ testbench very fast simulates ARM v2a CPU/Serial work!

"Hello world" app is built from sw/hello-world-my then tesbench loads hello-world.mem into static ram of SoC where it starts by CPU
during simulation.
