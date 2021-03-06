// ============================================================================
//   Ver  :| Author					:| Mod. Date :| Changes Made:
//   V1.1 :| Alexandra Du			:| 06/01/2016:| Added Verilog file
// ============================================================================


//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
//`define ENABLE_CLOCK2
//`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
//`define ENABLE_VGA
//`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

module DE10_LITE_Golden_Top(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);

// Clock and Reset

wire base_clk, mem_clk, cpu_clk, pre_clk;
wire rst, hlt;
wire branch_taken;

ClockDivider clk_div(
	.clk_in(MAX10_CLK1_50),
	.clk_out(pre_clk),
	.rst(rst)
);
defparam clk_div.DIVISOR = 1_000_000;
defparam clk_div.FIRST_EDGE = 1;
assign base_clk = pre_clk & !hlt;

//assign base_clk = ~KEY[0];
ClockGenerator clk_gen(
	.base_clk(base_clk),
	.cpu_clk(cpu_clk),
	.mem_clk(mem_clk),
	.rst(rst)
);

// CPU and Memory

wire [31:0] mem_addr, mem_data;
wire [1:0] mem_size;
wire mem_rw;
wire instr_finish;

RiscVCore cpu(
	.mem_addr(mem_addr),
	.mem_data(mem_data),
	
	.mem_size(mem_size),
	.mem_rw(mem_rw),
	
	.branch_taken(branch_taken),
	.instr_finish(instr_finish),
	
	.clk(cpu_clk),
	.rst(rst),
	.hlt(hlt)
);
MemoryController mem(
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	
	.clk(mem_clk)
);
IOController #(.IO_ADDR(32'h8000_0000)) io (
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	.clk(mem_clk),
	
	.LEDR(LEDR),
	.SW(SW)
);
SevenSegmentController #(.ADDR(32'h8000_0004)) sseg (
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	.clk(mem_clk),
	
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3)
);

PerformanceCounter #(.ADDR(32'h8000_0008)) instr_counter (
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	.clk(mem_clk),
	.inc(instr_finish)
);
PerformanceCounter #(.ADDR(32'h8000_000c)) clock_counter (
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	.clk(mem_clk),
	.inc(cpu_clk)
);
GPIOController #(.ADDR(32'h8000_0010)) gpio (
	.addr(mem_addr),
	.data(mem_data),
	.size(mem_size),
	.rw(mem_rw),
	.clk(mem_clk),
	.gpio(ARDUINO_IO)
);

// Assignments
assign HEX5[0] = ~hlt;
assign HEX5[1] = ~base_clk;
assign HEX5[2] = ~branch_taken;
assign HEX5[3] = ~instr_finish;
assign HEX5[7:4] = 4'b1111;

endmodule
