This folder contains files neccessary to do simulation of Linux start in Amber system.
In Windows OS use "c_sdr.bat" to start compiling project with Icarus Verilog.
Icarus Verilog should be installed first.
File "srclist_sdr" contains list of all neccessary Amber Project verilog sources.
Main file for simulation is testbench file "tb_sdr.v". It is also in the list of "srclist_sdr".
Icarus Verilog will use this list to compile.
Output of compilier is file "qqq" (strange name, isn't it? :-) ).
Then run simulation with command "vvp qqq".
Icarus Verilog will simulate system.
This testbench "tb_sdr.v" starts Linux.
Bootram memory content is defined by "hello-world.mem" file.
Linux memory content is defined by "vmlinux.mem" file.
SDRAM is used as Micron verilog model.

Here is log of compilation and simulation:
--------------------------------
c:\Altera\Amber-Marsohod2\hw\marsohod2\my_tb\vmlinux>vvp qqq
VCD info: dumpfile out.vcd opened for output.
reseting..
Load boot memory from boot-loader.mem
Read in 2031 lines
Load Linux into memory vmlinux.mem
Read in 279925 lines
log file tests.log, timeout 0, test name my ARM simulation
go..
tb.u_mt48lc4m16 : at time 5734406.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 7392056.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 10418231.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 10880831.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 14504531.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 16451306.0 ns ERROR: tRAS violation during Precharge
Linux version 2.4.27-vrs1 (nick@ubuntu) (gcc version 4.6.3 (Sourcery CodeBench Li
PST 2012
CPU: Amber 2 revision 0
Machine: Amber-FPGA-System
On node 0 totalpages: 256
zone(0): 256 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Kernel command line: console=ttyAM0 mem=8M
19.91 BogoMIPS (preset value used)
tb.u_mt48lc4m16 : at time 22812056.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 26782706.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 26879081.0 ns ERROR: tRAS violation during Precharge
Memory: 8MB = 8MB total
tb.u_mt48lc4m16 : at time 27707906.0 ns ERROR: tRAS violation during Precharge
Memory: 6272KB available (796K code, 224K data, 64K init)
tb.u_mt48lc4m16 : at time 32064056.0 ns ERROR: tRAS violation during Precharge
Dentry cache hash table entries: 4096 (order: 0, 32768 bytes)
Inode cache hash table entries: 4096 (order: 0, 32768 bytes)
Mount cache hash table entries: 4096 (order: 0, 32768 bytes)
tb.u_mt48lc4m16 : at time 41412431.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 42337631.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 42800231.0 ns ERROR: tRAS violation during Precharge
Buffer cache hash table entries: 8192 (order: 0, 32768 bytes)
Page-cache hash table entries: 8192 (order: 0, 32768 bytes)
tb.u_mt48lc4m16 : at time 51898031.0 ns ERROR: tRAS violation during Precharge
POSIX conformance testing by UNIFIX
arch_kernel_thread
do_fork           1
do_fork enter
do_fork exit
arch_kernel_thread exit
tb.u_mt48lc4m16 : at time 55020581.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 57815456.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 58258781.0 ns ERROR: tRAS violation during Precharge
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
arch_kernel_thread
do_fork           2
do_fork enter
tb.u_mt48lc4m16 : at time 66084431.0 ns ERROR: tRAS violation during Precharge
do_fork exit
arch_kernel_thread exit
arch_kernel_thread
do_fork           3
do_fork enter
do_fork exit
arch_kernel_thread exit
tb.u_mt48lc4m16 : at time 70845356.0 ns ERROR: tRAS violation during Precharge
tb.u_mt48lc4m16 : at time 70864631.0 ns ERROR: tRAS violation during Precharge
Starting kswapd
arch_kernel_thread
do_fork           4
tb.u_mt48lc4m16 : at time 71654906.0 ns ERROR: tRAS violation during Precharge
do_fork enter
do_fork exit
arch_kernel_thread exit
tb.u_mt48lc4m16 : at time 73370381.0 ns ERROR: tRAS violation during Precharge
arch_kernel_thread
do_fork           5
tb.u_mt48lc4m16 : at time 73832981.0 ns ERROR: tRAS violation during Precharge
do_fork enter
** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 85808681250 ticks.
> finish
