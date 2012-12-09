
`timescale  1 ns / 1 ns

module tb();

reg                     sysrst;
reg                     clk_80mhz;
reg [31:0]              clk_count = 'd0;

integer                 log_file;

integer                 boot_mem_file;
reg     [31:0]          boot_mem_file_address;
reg		[1:0]mem_bank;
reg     [31:0]          boot_mem_file_data;
reg     [127:0]         boot_mem_file_data_128;
integer                 boot_mem_line_count;
integer                 fgets_return;
reg     [120*8-1:0]     line;
reg     [120*8-1:0]     aligned_line;
integer                 timeout = 0;

wire                    uart0_cts;
wire                    uart0_rx;
wire                    uart0_rts;
wire                    uart0_tx;
wire 	led;

`include "debug_functions.v"

`define AMBER_TEST_NAME         "my ARM simulation"
`define BOOT_MEM_FILE           "boot-loader.mem"
`define LINUX_MEM_FILE          "vmlinux.mem"
`define AMBER_LOG_FILE          "tests.log"
`define AMBER_UART_BAUD 921600

wire w_sdr_clk;
wire w_sdr_ras_n;
wire w_sdr_cas_n;
wire w_sdr_we_n;
wire [1:0]w_sdr_dqm;
wire [1:0]w_sdr_ba;
wire [11:0]w_sdr_addr;
wire [15:0]w_sdr_dq;
	
// ======================================
// Instantiate FPGA
// ======================================
msystem u_system (
    // Clocks and resets
    .brd_n_rst          ( sysrst            ),
    .brd_clk_p          ( clk_80mhz        ),
    
    // UART 0 signals
    //.o_uart0_cts        ( uart0_cts         ),
    .o_uart0_rx         ( uart0_rx          ),
    //.i_uart0_rts        ( uart0_rts         ),
    .i_uart0_tx         ( uart0_tx          ),
        
	.led				(led),
	
	.sdr_clk( w_sdr_clk),
    .sdr_ras_n( w_sdr_ras_n ),
    .sdr_cas_n( w_sdr_cas_n ),
    .sdr_we_n( w_sdr_we_n ),
    .sdr_dqm( w_sdr_dqm ),
    .sdr_ba( w_sdr_ba ),
    .sdr_addr( w_sdr_addr ),
    .sdr_dq( w_sdr_dq )
);

//instance of sdram model
mt48lc4m16a2 u_mt48lc4m16
    (
     .Addr(w_sdr_addr),
     .Dq  (w_sdr_dq),
     .Ba  (w_sdr_ba),
     .Dqm (w_sdr_dqm),
     .Clk  (w_sdr_clk),
     .Cke  (1'b1),
     .We_n  (w_sdr_we_n),
     .Ras_n (w_sdr_ras_n),
     .Cs_n  (1'b0),
     .Cas_n (w_sdr_cas_n)
	 );
	 
// ======================================
// Instantiate Testbench UART
// ======================================
tb_uart u_tb_uart (
    .i_uart_cts_n   ( uart0_cts ),          // Clear To Send
    .i_uart_rxd     ( uart0_rx  ),
    .o_uart_rts_n   ( uart0_rts ),          // Request to Send
    .o_uart_txd     ( uart0_tx  )
);

// ======================================
// Clock and Reset
// ======================================

// 80 MHz clock
initial
    begin
    clk_80mhz = 1'd0;
    // Time unit is nano-seconds
    forever #6.25 clk_80mhz = ~clk_80mhz;
    end
    
initial
    begin
	$dumpfile("out.vcd");
    /*$dumpvars(0,tb.u_system.u_amber);*/
	$dumpvars(0,tb);
	$dumpoff;
	
	$display("reseting..");
    sysrst = 1'd0;
    #100
    sysrst = 1'd1;
	$display("go..");
    #500000000;
	$display("End of simulation!");
	$finish;
    end

integer ena_rec = 0;
integer prev_a = 0;
always @(posedge u_system.u_amber.i_clk)
	begin
		if(	u_system.u_amber.u_execute.i_pc_wen && 
			u_system.u_amber.i_system_rdy && 
			!u_system.u_amber.fetch_stall &&
			u_system.u_amber.u_decode.instruction_address != prev_a
			)
		begin	
			prev_a = u_system.u_amber.u_decode.instruction_address;
			
			if(u_system.u_amber.u_decode.instruction_address==32'h209c9f4)
			begin
				ena_rec = ena_rec+1;
				$display("do_fork %d",ena_rec);
				$fdisplay(log_file,"do_fork");
			end

			if(ena_rec==5)
			begin
				$dumpon;
			end
			
			if(ena_rec!=0)
			begin
			$fdisplay(log_file,"#%08X:%08X",
				u_system.u_amber.u_decode.instruction_address,
				u_system.u_amber.u_decode.instruction
				);
			$fdisplay(log_file,"  %08X %08X %08X %08X %08X %08X %08X %08X",
				u_system.u_amber.u_execute.u_register_bank.r0,
				u_system.u_amber.u_execute.u_register_bank.r1,
				u_system.u_amber.u_execute.u_register_bank.r2,
				u_system.u_amber.u_execute.u_register_bank.r3,
				u_system.u_amber.u_execute.u_register_bank.r4,
				u_system.u_amber.u_execute.u_register_bank.r5,
				u_system.u_amber.u_execute.u_register_bank.r6,
				u_system.u_amber.u_execute.u_register_bank.r7
				);
			$fdisplay(log_file,"  %08X %08X %08X %08X %08X %08X %08X %08X",
				u_system.u_amber.u_execute.u_register_bank.r8,
				u_system.u_amber.u_execute.u_register_bank.r9,
				u_system.u_amber.u_execute.u_register_bank.r10,
				u_system.u_amber.u_execute.u_register_bank.r11,
				u_system.u_amber.u_execute.u_register_bank.r12,
				u_system.u_amber.u_execute.u_register_bank.r13_svc,
				u_system.u_amber.u_execute.u_register_bank.r14_svc,
				u_system.u_amber.u_execute.u_register_bank.r15
				);
			end
		end
	end

// ======================================
// Counter of system clock ticks        
// ======================================
always @ ( posedge `U_SYSTEM.sys_clk )
    clk_count <= clk_count + 1'd1;

initial
        begin
`ifndef XILINX_FPGA
// ======================================
// Initialize Boot Memory
// ======================================
        $display("Load boot memory from %s", `BOOT_MEM_FILE);
        boot_mem_line_count   = 0;
        boot_mem_file         = $fopen(`BOOT_MEM_FILE,    "r");
        if (boot_mem_file == 0)
            begin
            `TB_ERROR_MESSAGE
            $display("ERROR: Can't open input file %s", `BOOT_MEM_FILE);
            end
        
        if (boot_mem_file != 0)
            begin  
            fgets_return = 1;
            while (fgets_return != 0)
                begin
                fgets_return        = $fgets(line, boot_mem_file);
                boot_mem_line_count = boot_mem_line_count + 1;
                aligned_line        = align_line(line);
                
                // if the line does not start with a comment
                if (aligned_line[120*8-1:118*8] != 16'h2f2f)
                    begin
                    // check that line doesnt start with a '@' or a blank
                    if (aligned_line[120*8-1:119*8] != 8'h40 && aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        $display("Format ERROR in input file %s, line %1d. Line must start with a @, not %08x", 
                                 `BOOT_MEM_FILE, boot_mem_line_count, aligned_line[118*8-1:117*8]);
                        `TB_ERROR_MESSAGE
                        end
                    
                    if (aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        boot_mem_file_address  =   hex_chars_to_32bits (aligned_line[119*8-1:111*8]);
                        boot_mem_file_data     =   hex_chars_to_32bits (aligned_line[110*8-1:102*8]);
                        
                        `ifdef AMBER_A25_CORE
                            boot_mem_file_data_128 = `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[12:4]];
                            `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[12:4]] = 
                                    insert_32_into_128 ( boot_mem_file_address[3:2], 
                                                         boot_mem_file_data_128, 
                                                         boot_mem_file_data );
                        `else
                            `U_BOOT_MEM.u_mem.mem[boot_mem_file_address[12:2]] = boot_mem_file_data;
                        `endif
                        
                        `ifdef AMBER_LOAD_MEM_DEBUG
                            $display ("Load Boot Mem: PAddr: 0x%08x, Data 0x%08x", 
                                        boot_mem_file_address, boot_mem_file_data);
                        `endif   
                        end
                    end  
                end
                
            $display("Read in %1d lines", boot_mem_line_count);      
            end
`endif

// ======================================
// Load Linux into SDR Memory
// ======================================
        $display("Load Linux into memory ", `LINUX_MEM_FILE);
        boot_mem_line_count   = 0;
        boot_mem_file         = $fopen(`LINUX_MEM_FILE,    "r");
        if (boot_mem_file == 0)
            begin
            `TB_ERROR_MESSAGE
            $display("ERROR: Can't open input file %s", `LINUX_MEM_FILE);
            end
        
        if (boot_mem_file != 0)
            begin  
            fgets_return = 1;
            while (fgets_return != 0)
                begin
                fgets_return        = $fgets(line, boot_mem_file);
                boot_mem_line_count = boot_mem_line_count + 1;
                aligned_line        = align_line(line);
                
                // if the line does not start with a comment
                if (aligned_line[120*8-1:118*8] != 16'h2f2f)
                    begin
                    // check that line doesnt start with a '@' or a blank
                    if (aligned_line[120*8-1:119*8] != 8'h40 && aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        $display("Format ERROR in input file %s, line %1d. Line must start with a @, not %08x", 
                                 `LINUX_MEM_FILE, boot_mem_line_count, aligned_line[118*8-1:117*8]);
                        `TB_ERROR_MESSAGE
                        end
                    
                    if (aligned_line[120*8-1:119*8] != 8'h00)
                        begin
                        boot_mem_file_address  =   hex_chars_to_32bits (aligned_line[119*8-1:111*8]);
                        boot_mem_file_data     =   hex_chars_to_32bits (aligned_line[110*8-1:102*8]);
						boot_mem_file_address = boot_mem_file_address >> 1;
						mem_bank = boot_mem_file_address[9:8];
						boot_mem_file_address = { boot_mem_file_address[31:10], boot_mem_file_address[7:0] };
						//$display("ad %d %08x %08X",mem_bank,boot_mem_file_address,boot_mem_file_data);
						case(mem_bank)
						0:	begin
								u_mt48lc4m16.Bank0[boot_mem_file_address[31:0]+0] = boot_mem_file_data[15:0];
								u_mt48lc4m16.Bank0[boot_mem_file_address[31:0]+1] = boot_mem_file_data[31:16];
							end
						1:	begin
								u_mt48lc4m16.Bank1[boot_mem_file_address[31:0]+0] = boot_mem_file_data[15:0];
								u_mt48lc4m16.Bank1[boot_mem_file_address[31:0]+1] = boot_mem_file_data[31:16];
							end
						2:	begin
								u_mt48lc4m16.Bank2[boot_mem_file_address[31:0]+0] = boot_mem_file_data[15:0];
								u_mt48lc4m16.Bank2[boot_mem_file_address[31:0]+1] = boot_mem_file_data[31:16];
							end
						3:	begin
								u_mt48lc4m16.Bank3[boot_mem_file_address[31:0]+0] = boot_mem_file_data[15:0];
								u_mt48lc4m16.Bank3[boot_mem_file_address[31:0]+1] = boot_mem_file_data[31:16];
							end
						endcase
                        end
                    end  
                end
                
            $display("Read in %1d lines", boot_mem_line_count);      
            end
            
        // Grab the test name from memory    
        timeout   = `AMBER_TIMEOUT   ;           
        $display("log file %s, timeout %0d, test name %0s ", `AMBER_LOG_FILE, timeout, `AMBER_TEST_NAME );          
        log_file = $fopen(`AMBER_LOG_FILE, "a");                               
        end

// ======================================
reg testfail;
initial
begin
	testfail  = 1'd0;
end

// ======================================
// Functions
// ======================================
function [127:0] insert_32_into_128;
input [1:0]   pos;
input [127:0] word128;
input [31:0]  word32;
begin
     case (pos)
         2'd0: insert_32_into_128 = {word128[127:32], word32};
         2'd1: insert_32_into_128 = {word128[127:64], word32, word128[31:0]};
         2'd2: insert_32_into_128 = {word128[127:96], word32, word128[63:0]};
         2'd3: insert_32_into_128 = {word32, word128[95:0]};
     endcase
end
endfunction

endmodule

