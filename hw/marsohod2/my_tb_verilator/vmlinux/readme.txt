You need verilator to be installed.
Then build c++/Verilog testbench:
$ make

Then run testbench with command
$ ./obj_dir/Vtb

In few seconds output of testbench is:
----------------------------------------
Instantiating 8 MB SDRAM : 4 banks x 4096 rows x 256 cols x 16 bits
Starting row : 3584, starting bank : 0
Loading 0x00032000 bytes @ 0x00700000 from binary file "initrd"...OK
Load mem file: vmlinux.mem
Mem-02080000-e35f0402-
Mem-02080004-b59ff034-
Mem-02080008-e3300000-
Mem-0208000c-1b000013-
Mem-02080010-e28f0028-
Mem-02080014-e990203c-
Mem-02080018-e3a00000-
Mem-0208001c-e1520003-
Mem-02080020-34820004-
Starting row : 0, starting bank : 0
Loading 0x0018D790 bytes @ 0x00000000 from binary file "tmp.dat"...OK
Load boot memory from boot-loader.mem
Read in 2014 lines
log file tests.log, timeout 0, test name my ARM simulation 
Linux version 2.4.27-vrs1 (nick@ubuntu) (gcc version 4.5.2 (Sourcery G++ Lite 2011.03-46) ) #1 Tue Jan 22 23:48:37 PST 2013
CPU: Amber 2 revision 0
Machine: Amber-FPGA-System
On node 0 totalpages: 256
zone(0): 256 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Kernel command line: console=ttyAM0 mem=8M root=/dev/ram
19.91 BogoMIPS (preset value used)
Memory: 8MB = 8MB total
Memory: 6304KB available (783K code, 222K data, 64K init)
Dentry cache hash table entries: 4096 (order: 0, 32768 bytes)
Inode cache hash table entries: 4096 (order: 0, 32768 bytes)
Mount cache hash table entries: 4096 (order: 0, 32768 bytes)
Buffer cache hash table entries: 8192 (order: 0, 32768 bytes)
Page-cache hash table entries: 8192 (order: 0, 32768 bytes)
POSIX conformance testing by UNIFIX
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
Starting kswapd
ttyAM0 at MMIO 0x16000000 (irq = 1) is a WSBN
pty: 256 Unix98 ptys configured
Serial driver version 5.05c (2001-07-08) with no serial options enabled
ttyS00 at 0x03f8 (irq = 10) is a 16450
ttyS01 at 0x02f8 (irq = 10) is a 16450
RAMDISK driver initialized: 16 RAM disks of 208K size 1024 blocksize
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 4096 bind 8192)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
RAMDISK: ext2 filesystem found at block 0
RAMDISK: Loading 200 blocks [1 disk] into ram disk... done.
Freeing initrd memory: 200K
VFS: Mounted root (ext2 filesystem) readonly.
Freeing init memory: 64K
BINFMT_FLAT: Loading file: /sbin/init
Mapping is 2b0000, Entry point is 8068, data_start is 8e4c
Load /sbin/init: TEXT=2b0040-2b8e4c DATA=2b8e50-2b8e83 BSS=2b8e83-2b8e88
start_thread(regs=0x21f9fa4, entry=0x2b8068, start_stack=0x2affb4)
Hello, World!
Hello, Marsohod!
----------------------------------------
This is serial console output of SoC Amber prepared for marsohod2 FPGA board.
C++ testbench very fast simulates CPU/SDRAM/Serial work!

In this Testbench vmlinux (at 0x80000) and initrd (at 0x700000) are loaded into SoC SDRAM memory and then 
C++/Verilog SoC system starts simulated with verilator.
Specific bootloader from sw/boot-loader-tl only makes few things before jump to 0x80000 where linux is placed.
Linux boots in 10 seconds - much less then when simulated with Icarus Verilog.

