
module ps2recv(
	input  wire clk,
	input  wire ps2_clk,
	input  wire ps2_data,
	output wire rbyte_ready,
	output wire [7:0]rbyte,
	output wire poll_imp
);

reg [5:0]poll_cnt;
assign poll_imp = (poll_cnt==0);
always @(posedge clk)
	poll_cnt <= poll_cnt + 1;

reg [2:0]ps2_clk_;
reg [2:0]ps2_data_;

always @(posedge clk)
	if(poll_imp)
	begin
		ps2_clk_  <= { ps2_clk_ [1:0],ps2_clk  };
		ps2_data_ <= { ps2_data_[1:0],ps2_data };
	end

reg [7:0]imp_cnt;
wire eo_imp_cnt;  assign eo_imp_cnt  = (imp_cnt == 8'hFF);
wire eo_imp_cnt2; assign eo_imp_cnt2 = (imp_cnt == 8'hFE);
always @(posedge clk)
if(poll_imp)
begin
	if(ps2_clk_[2]==0)
		imp_cnt <= 0;
	else
	if(~eo_imp_cnt)
		imp_cnt <= imp_cnt + 1;
end

reg [10:0]rword=0;
assign rbyte = rword[8:1];
assign rbyte_ready = poll_imp & (rword[0]==1'b0);
always @(posedge clk)
	if( rbyte_ready || eo_imp_cnt2 )
		rword <= 11'h7ff;
	else
	if(ps2_clk_[2:1]==2'b10 && poll_imp)
		rword <= { ps2_data_[2], rword[10:1] };

endmodule
