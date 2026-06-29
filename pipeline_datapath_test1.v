`timescale 1ns / 1ps

module pipeline_datapath_test1;

    // Testbench signals
	 //Input
    reg clk;
    reg rst;
	 reg [7:0]instruction_address;
	 reg [31:0]instruction;
	 reg instruction_write;
	 reg pc_enable;
	 
	 //Output
    wire [31:0] debug_pc;
    wire [63:0] debug_reg0;
    wire [63:0] debug_reg1;
    wire [31:0] debug_instruction;
	 wire [1:0] thread;
	 
    pipeline_datapath uut (
        .clk(clk),
        .rst(rst),
		  .addressB(addressB),
        .debug_pc(debug_pc),
        .debug_reg0(debug_reg0),
        .debug_reg1(debug_reg1),
        .debug_instruction(debug_instruction),
		  .instruction_address(instruction_address),
		  .instruction(instruction),
		  .instruction_write(instruction_write),
		  .pc_enable(pc_enable),
		  .thread(thread)
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
		  instruction_write = 1'b1;
 
		  instruction_address = 8'h0;
		  instruction = 32'he320f000;          // NOP
		  instruction_address = 8'h1;
		  instruction = 32'he320f000;          // NOP
		  instruction_address = 8'h2;
		  instruction = 32'he320f000;          // NOP
		  #10
		  instruction_address = 8'h3;
		  instruction = 32'he3a00000;          // MOV R0, #0
		  #10
		  instruction_address = 8'h4;
		  instruction = 32'he4901040;          // LDR R1, [R0, #0x40]  -> addr 0x100 (CACHE HIT expected)
		  #10
		  instruction_address = 8'h5;
		  instruction = 32'he4902080;          // LDR R2, [R0, #0x80]  -> addr 0x200 (CACHE MISS expected)
		  #10
		  instruction_address = 8'h6;
		  instruction = 32'he4903080;          // LDR R3, [R0, #0x80]  -> addr 0x200 again (CACHE HIT expected, post-fill)
		  #10
		  instruction_address = 8'h7;
		  instruction = 32'he320f000;          // NOP padding
		  #10
		  instruction_address = 8'h8;
		  instruction = 32'he320f000;          // NOP padding
		  #10
		  instruction_address = 8'h9;
		  instruction = 32'he320f000;          // NOP padding
		  instruction_write = 1'b0;
		  #10
		  pc_enable = 1;
		  //Start
    end

  

endmodule
