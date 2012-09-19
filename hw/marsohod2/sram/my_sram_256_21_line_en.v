// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module my_sram_256_21_line_en (
	input wire [7:0]i_address,
	input wire i_clk,
	input wire [20:0]i_write_data,
	input wire i_write_enable,
	output wire [20:0]o_read_data
	);
parameter DATA_WIDTH = 21;
parameter INITIALIZE_TO_ZERO = 1;
parameter ADDRESS_WIDTH = 8;

sram_256_21_line_en sram(
	.address(i_address),
	.clock(i_clk),
	.data(i_write_data),
	.wren(i_write_enable),
	.q(o_read_data)
	);
	
endmodule
