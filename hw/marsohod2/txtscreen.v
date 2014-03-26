
///////////////////////////////////////////////////////////////
//module which generates video sync impulses
///////////////////////////////////////////////////////////////

module txtscreen (
	// inputs:
	input wire pixel_clock,
	input wire in_ps2_clock,
	input wire in_ps2_data,

	// outputs:
	output reg hsync,
	output reg vsync,

	//high-color test video signal
	output reg [4:0]r,
	output reg [5:0]g,
	output reg [4:0]b,
	
	//wishbone interface
	input wire i_wb_clk,
   input wire [31:0]i_wb_dat,
   input wire [31:0]i_wb_adr,
   input wire i_wb_sel,
   input wire i_wb_we,
   input wire i_wb_cyc,
   input wire i_wb_stb,
   output wire [31:0]o_wb_dat,
   output wire o_wb_ack,
   output wire o_wb_err
	);
	
	// video signal parameters, default 1440x900 60Hz
	parameter horz_front_porch = 80;
	parameter horz_sync = 152;
	parameter horz_back_porch = 232;
	parameter horz_addr_time = 1440;
	
	parameter vert_front_porch = 3;
	parameter vert_sync = 6;
	parameter vert_back_porch = 25;
	parameter vert_addr_time = 900;
	
	//variables	
	reg [11:0]pixel_count = 0;
	reg [11:0]line_count = 0;

reg hvisible = 1'b0;
reg vvisible = 1'b0;
reg visible  = 1'b0;
reg hfetch = 1'b0;

reg [12:0]scr_addr;
reg [11:0]fnt_addr;

//synchronous process
always @(posedge pixel_clock)
begin
	hsync <= (pixel_count >= (horz_addr_time+horz_front_porch) && pixel_count < (horz_addr_time+horz_front_porch+horz_sync) );
	
	if(pixel_count < (horz_addr_time+horz_front_porch+horz_sync+horz_back_porch-1) )
		pixel_count <= pixel_count + 1'b1;
	else
		pixel_count <= 0;
end

always @(posedge hsync)
begin
	vsync <= (line_count >= (vert_addr_time+vert_front_porch) &&  line_count < (vert_addr_time+vert_front_porch+vert_sync) );
	
	if(line_count < (vert_sync+vert_back_porch+vert_addr_time+vert_front_porch -1) )
		line_count <= line_count + 1'b1;
	else
		line_count <= 0;
end

reg [4:0]framecnt;
always @(posedge vsync)
	framecnt <= framecnt + 1;

always @*
begin
	hfetch = (pixel_count < horz_addr_time-5) || (pixel_count > (horz_addr_time+horz_front_porch+horz_sync+horz_back_porch-6));
	hvisible = (pixel_count < horz_addr_time);
	vvisible = (line_count < vert_addr_time);
	visible = hvisible & vvisible;

	r = {rr,rr,3'h0};
	g = {gg,gg,3'h0,visible};
	b = {bb,bb,3'h0};
end

reg [2:0]get_char_line;

always @*
begin
	if(pixel_count[10:4]>8'h60)
		scr_addr = { line_count[9:4], 7'h00 };
	else
		scr_addr = { line_count[9:4], pixel_count[10:4] + 1'b1 };
	fnt_addr = { scr_char[7:0], line_count[3:0] };
end

reg [15:0]scr_char;
reg [7:0]scr_char_line;

reg [2:0]fcolor;
reg [2:0]bcolor;

reg rr,gg,bb;

reg sbit;
always @*
begin
/*
	case(pixel_count[3:1])
		3'd0: sbit = scr_char_line[2];
		3'd1: sbit = scr_char_line[1];
		3'd2: sbit = scr_char_line[0];
		3'd3: sbit = scr_char_line[7];
		3'd4: sbit = scr_char_line[6];
		3'd5: sbit = scr_char_line[5];
		3'd6: sbit = scr_char_line[4];
		3'd7: sbit = scr_char_line[3];
	endcase
*/
	sbit = scr_char_line[ 3'h7 - pixel_count[3:1] ];
end

always @(posedge pixel_clock)
begin
	get_char_line <= { get_char_line[1:0],( pixel_count[3:0]==4'hC ) & vvisible &  hfetch} ;

	if(get_char_line[0])
		scr_char <= scr_data;

	if(get_char_line[2])
	begin
		scr_char_line <= fnt_data;
		fcolor <= scr_char[10: 8];
		bcolor <= scr_char[14:12];
	end

	if(visible)
	begin
		rr <= sbit ? fcolor[2] : bcolor[2] | cursor_visible;
		gg <= sbit ? fcolor[1] : bcolor[1] | cursor_visible;
		bb <= sbit ? fcolor[0] : bcolor[0] | cursor_visible;
	end
	else
	begin
		rr <= 1'b0;
		bb <= 1'b0;
		gg <= 1'b0;
	end
end

//memory work here
wire [7:0]fnt_data;
wire [15:0]scr_data;

rom_font my_rom_font(
	.address( fnt_addr ),
	.clock( pixel_clock ),
	.q( fnt_data )
);

wire my_scr_wr; assign my_scr_wr = i_wb_stb & i_wb_we;

screen2 my_screen2 (
	.data( i_wb_dat[15:0] ),
	.rdaddress( scr_addr ),
	.rdclock( pixel_clock ),
	.wraddress( i_wb_adr[14:2] ),
	.wrclock( i_wb_clk ),
	.wren( my_scr_wr & (i_wb_adr[15]==1'b0) ), //i_wb_cyc & i_wb_sel ???
	.q( scr_data )
);

reg [15:0]cursor_info;
always @(posedge i_wb_clk)
	if( my_scr_wr & (i_wb_adr[15]==1'b1) )
		cursor_info <= i_wb_dat[15:0];

wire cursor_visible;
assign cursor_visible = 
	(pixel_count[10:4] == cursor_info[ 6:0]) &&
	(line_count [10:4] == cursor_info[14:8]) &&
	(line_count [3:0]>10) &&
	(framecnt[4]);
	
//wishbone interface
assign o_wb_ack = i_wb_stb; // ???
assign o_wb_dat = i_wb_adr[2] ? ps2_rbyte_f[63:32] : ps2_rbyte_f[31:0];
assign o_wb_err = 1'b0;

wire ps2_rbyte_ready;
wire [7:0]ps2_rbyte;
reg [63:0]ps2_rbyte_f;
reg [3:0]ps2counter;

always @(posedge i_wb_clk)	
	if(ps2_rbyte_ready)
	begin
		ps2counter  <= ps2counter + 1;
		ps2_rbyte_f <= { ps2_rbyte_f[47:0], 4'b0, ps2counter, ps2_rbyte };
	end
	
ps2recv my_ps2recv(
	.clk( i_wb_clk ),
	.ps2_clk( in_ps2_clock ),
	.ps2_data( in_ps2_data ),
	.rbyte_ready( ps2_rbyte_ready ),
	.rbyte( ps2_rbyte ),
	.poll_imp()
);


endmodule

