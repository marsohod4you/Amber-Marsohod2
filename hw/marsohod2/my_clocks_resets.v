
//
// Clocks and Resets Module
//

module my_clocks_resets (
	input	wire	i_brd_rst, //from board button
	input	wire	i_brd_clk, //from board crystal
	input wire  i_memory_initialized,
	output wire	o_sys_rst,
	output wire	o_sys_clk,
	output wire	o_mem_clk,
	output wire o_sdr_ena,
	output reg	o_system_ready
);
wire pll_clk40;
wire pll_clk80;
wire pll_locked;

`ifdef ICARUS
 //for simulation purposes just use incoming freq as memory clock
 //and system clock is half of incoming freq
 reg t=0;
 always @(posedge i_brd_clk)
	t <= ~t;
 assign o_sys_clk = t;
 assign o_mem_clk = i_brd_clk;
 assign pll_locked = 1'b1;
`else
 //for real system insert altera's PLL
 my_pll my_pll_inst (
	.inclk0(i_brd_clk),
	.areset(1'b0 /*i_brd_rst*/ ),
	.c0(o_sys_clk), //40Mhz
	.c1(o_mem_clk), //80Mhz
	.locked(pll_locked)
	);
`endif

//enable SRDAM only after timeout, when counter reaches 0x8000
reg [15:0]cnt = 0;
assign o_sdr_ena = cnt[15];

always @(posedge o_sys_clk or posedge i_brd_rst)
	if(i_brd_rst)
		cnt <= 0;
	else
		if( (!o_sdr_ena) && pll_locked )
			cnt <= cnt + 1'b1;
		
assign o_sys_rst = ~(|cnt[15:8]);

//one clock delay for system ready signal regarding reset
initial
	o_system_ready = 0;

always @(posedge o_sys_clk)
	o_system_ready <= (~o_sys_rst) & i_memory_initialized;

endmodule


