// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module my_sram_256_128_byte_en (
	input wire [7:0]i_address,
	input wire [15:0]i_byte_enable,
	input wire i_clk,
	input wire [127:0]i_write_data,
	input wire i_write_enable,
	output wire [127:0]o_read_data
	);

parameter DATA_WIDTH = 128;
parameter ADDRESS_WIDTH = 8;

sram_256_128_byte_en sram(
	.address(i_address),
	.byteena(i_byte_enable),
	.clock(i_clk),
	.data(i_write_data),
	.wren(i_write_enable),
	.q(o_read_data)
	);
	
endmodule
