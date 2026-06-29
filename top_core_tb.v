`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:34:11 06/22/2026
// Design Name:   top_core
// Module Name:   C:/Documents and Settings/student/Multicore_all/dualcore/top_core_tb.v
// Project Name:  dualcore
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_core
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_core_tb;

	// Inputs
	reg clk;
	reg rst;
	reg pc_enable;
	reg [7:0] instruction_address1;
	reg [31:0] instruction1;
	reg instruction_write1;
	reg [7:0] instruction_address2;
	reg [31:0] instruction2;
	reg instruction_write2;

	// Outputs
	wire [1:0] thread1;
	wire [1:0] thread2;

	// Instantiate the Unit Under Test (UUT)
	top_core uut (
		.clk(clk), 
		.rst(rst), 
		.pc_enable(pc_enable), 
		.instruction_address1(instruction_address1), 
		.instruction1(instruction1), 
		.instruction_write1(instruction_write1), 
		.thread1(thread1), 
		.instruction_address2(instruction_address2), 
		.instruction2(instruction2), 
		.instruction_write2(instruction_write2), 
		.thread2(thread2)
	);
	
	
    // ============================================
    // Clock Generation (10ns period)
    // ============================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz clock
    end

    // ============================================
    // Reset and Simulation Control
    // ============================================
    initial begin

 // Initialize reset
        rst = 1;
		  pc_enable = 0;
        #10;
        rst = 0;
		  instruction_write1 = 1'b1;
		  instruction_address1 = 8'h0;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'h1;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'h2;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'h3;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'h4;
		  instruction1 = 32'he3a01001;          // MOVI
		  #10
		  instruction_address1 = 8'h5;
		  instruction1 = 32'he3a02002;          // MOVI
		  #10
		  instruction_address1 = 8'h6;
		  instruction1 = 32'he3a03003;          // MOVI
		  #10
		  instruction_address1 = 8'h7;
		  instruction1 = 32'he3a04004;          // MOVI
		  #10
		  instruction_address1 = 8'h8;
		  instruction1 = 32'he5801001;          // SW
		  #10
		  instruction_address1 = 8'h9;
		  instruction1 = 32'he5802002;          // SW
		  #10
		  instruction_address1 = 8'ha;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'hb;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'hc;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'hd;
		  instruction1 = 32'he5903003;          // LW
		  #10
		  instruction_address1 = 8'he;
		  instruction1 = 32'he5904004;          // LW
		  #10
		  instruction_address1 = 8'hf;
		  instruction1 = 32'he5905001;          // LW
		  #10
		  instruction_address1 = 8'h10;
		  instruction1 = 32'he320f000;          // NOP
		  #10
		  instruction_address1 = 8'h11;
		  instruction1 = 32'he320f000;          // NOP
		  instruction_write1=1'b0;
		  #10
		  instruction_write2 = 1'b1;
		  instruction_address2 = 8'h0;
		  instruction2 = 32'he320f000;          // NOP
		  #10
		  instruction_address2 = 8'h1;
		  instruction2 = 32'he320f000;          // NOP
		  #10
		  instruction_address2 = 8'h2;
		  instruction2 = 32'he320f000;          // NOP
		  #10
		  instruction_address2 = 8'h3;
		  instruction2 = 32'he320f000;          // NOP
		  #10
		  instruction_address2 = 8'h4;
		  instruction2 = 32'he3a01005;          // MOVI
		  #10
		  instruction_address2 = 8'h5;
		  instruction2 = 32'he3a02006;          // MOVI
		  #10
		  instruction_address2 = 8'h6;
		  instruction2 = 32'he3a03007;          // MOVI
		  #10
		  instruction_address2 = 8'h7;
		  instruction2 = 32'he3a04008;          // MOVI
		  #10
		  instruction_address2 = 8'h8;
		  instruction2 = 32'he5801003;          // SW
		  #10
		  instruction_address2 = 8'h9;
		  instruction2 = 32'he5802004;          // SW
		  #10
		  instruction_address2 = 8'ha;
		  instruction2 = 32'he5803001;          // SW
		  #10
		  instruction_address2 = 8'hb;
		  instruction2 = 32'he5804002;          // SW
		  #10
		  instruction_address2 = 8'hc;
		  instruction2 = 32'he320f000;          // NOP
		  #10
		  instruction_address2 = 8'hd;
		  instruction2 = 32'he320f000;          // NOP
		  instruction_write2=1'b0;
		  #10
		  pc_enable=1'b1;
		  end
		  
      
endmodule

