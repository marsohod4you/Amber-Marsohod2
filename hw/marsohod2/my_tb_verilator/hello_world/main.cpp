#include <verilated.h>
#if VM_TRACE
#include "verilated_vcd_c.h"
#endif

#include "Vtb.h"

vluint64_t main_time = 0;

double sc_time_stamp ()
{
	return main_time;
}

int main(int argc, char **argv, char **env)
{
	if (0 && argc && argv && env) {}
	Vtb* tb = new Vtb;

	Verilated::commandArgs(argc, argv);
	Verilated::debug(0);

	tb->sysrst = 0;
	tb->clk_80mhz = 0;

#ifdef VM_TRACE
	VerilatedVcdC* vcd = nullptr;
	const char* flag = Verilated::commandArgsPlusMatch("trace");
	if (flag && 0==strcmp(flag, "+trace"))
	{
		printf("VCD waveforms will be saved!\n");
		Verilated::traceEverOn(true);	// Verilator must compute traced signals
		vcd = new VerilatedVcdC;
		tb->trace(vcd, 99);	// Trace 99 levels of hierarchy
		vcd->open("out.vcd");		// Open the dump file
	}
#endif

	int clock = 0;
	while (!Verilated::gotFinish())
	{
		clock^=1;
		tb->clk_80mhz = clock;
		if(main_time>100 )
			tb->sysrst = 1;
		if(main_time%9==0 )
			tb->clk_uart = ~tb->clk_uart;
		main_time++;
		//if( main_time>50000 ) break;
		tb->eval();
#if VM_TRACE
		if( vcd )
			vcd->dump(main_time);
#endif
	}

	tb->final();
#if VM_TRACE
	if( vcd )
		vcd->close();
#endif
	exit(0);
}
