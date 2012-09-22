
//
// Clocks and Resets Module
//

module my_clocks_resets (
	input	wire	i_brd_rst, //from board button
	input	wire	i_brd_clk, //from board crystal
	output wire	o_sys_rst,
	output reg	o_sys_clk,
	output wire	o_system_ready
);
wire pll_clk;
wire pll_locked;

`ifdef ICARUS
 assign pll_clk = i_brd_clk;
 assign pll_locked  = 1'b1;
`else
 //insert altera's PLL
 my_pll my_pll_inst (
	.inclk0(i_brd_clk),
	.areset(1'b0 /*i_brd_rst*/ ),
	.c0(pll_clk),
	.locked(pll_locked)
	);
`endif

reg [7:0]cnt;
always @(posedge pll_clk or posedge i_brd_rst)
	if(i_brd_rst)
		cnt<=0;
	else
		if( (!cnt[7]) && pll_locked )
			cnt <= cnt + 1'b1;
		
assign o_sys_rst = ~cnt[7];

always @(posedge pll_clk or posedge i_brd_rst)
	if(i_brd_rst)
		o_sys_clk <= 1'b0;
	else
		o_sys_clk <= o_sys_clk+1'b1;

assign o_system_ready = ~o_sys_rst;

endmodule


