#include <verilated.h>
#if VM_TRACE
#include "verilated_vcd_c.h"
#endif

#include "../sdr_sdram/sdr_sdram.h"
#include "Vtb.h"

double main_time = 0;
double sc_time_stamp ()
{
	return main_time;
}

int main(int argc, char **argv, char **env)
{
	if (0 && argc && argv && env) {}
	Vtb* top = new Vtb;

	// Init SDRAM C++ model (4096 rows, 512 cols)
	int sdram_flags = FLAG_DATA_WIDTH_16 | FLAG_BANK_INTERLEAVING;
	int rows_bits = 12; //4096
	int cols_bits = 8;  //256
	SDRAM* sdr  = new SDRAM( rows_bits, cols_bits, sdram_flags, nullptr );

	Verilated::commandArgs(argc, argv);
	Verilated::debug(0);

	top->sysrst = 0;
	top->clk_80mhz = 0;

#ifdef VM_TRACE
	VerilatedVcdC* vcd = nullptr;
	const char* flag = Verilated::commandArgsPlusMatch("trace");
	if (flag && 0==strcmp(flag, "+trace"))
	{
		printf("VCD waveforms will be saved!\n");
		Verilated::traceEverOn(true);	// Verilator must compute traced signals
		vcd = new VerilatedVcdC;
		top->trace(vcd, 99);	// Trace 99 levels of hierarchy
		vcd->open("out.vcd");		// Open the dump file
	}
#endif

	vluint64_t sdr_dq = 0;
	int clock = 0;
	int iT=0;
	while (!Verilated::gotFinish())
	{
		clock^=1;
		top->clk_80mhz = clock;
		if(main_time>50.0 )
			top->sysrst = 1;
		double dT=main_time/54.25347;
		if( (int)dT>iT )
		{
			top->clk_uart = ~top->clk_uart;
			iT=(int)dT;
		}
		main_time+=6.25;
		if( main_time>500000000.0 ) break;
		// "Read" from SDRAM, put to top
		top->sdr_dq = (vluint16_t)sdr_dq;
		top->eval();
		// Evaluate SDRAM C++ model
		vluint8_t  sdr_cs_n = 0;
		vluint8_t  sdr_cke  = 1;
		sdr->eval ( main_time,
			clock, sdr_cke,
			sdr_cs_n,  top->sdr_ras_n, top->sdr_cas_n, top->sdr_we_n,
			top->sdr_ba,    top->sdr_addr,
			top->sdr_dqm, (vluint64_t)top->sdr_dq, sdr_dq );

#if VM_TRACE
		if( vcd )
			vcd->dump(main_time);
#endif
	}

	top->final();
	delete sdr;
	delete top;

#if VM_TRACE
	if( vcd )
		vcd->close();
#endif
	exit(0);
}
