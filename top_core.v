`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:55:58 06/19/2026 
// Design Name: 
// Module Name:    top_core 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_core(input clk,rst,pc_enable,
input [7:0] instruction_address1,
input [31:0]instruction1,
input instruction_write1,
output [1:0] thread1,
input [7:0] instruction_address2,
input [31:0]instruction2,
input instruction_write2,
output [1:0] thread2
    );
	 
	 
wire [63:0] main_dmem_data;
wire [11:0] main_dmem_address;
wire [63:0] main_dmem_data_w;
wire [11:0] main_dmem_address_w;
wire main_dmem_wen;


wire [63:0] main_dmem_data_1;
wire [11:0] main_dmem_address_1;
wire [63:0] main_dmem_data_w_1;
wire [11:0] main_dmem_address_w_1;
wire main_dmem_wen_1;


wire [63:0] main_dmem_data_2;
wire [11:0] main_dmem_address_2;
wire [63:0] main_dmem_data_w_2;
wire [11:0] main_dmem_address_w_2;
wire main_dmem_wen_2;

wire [1:0] ctrl1,ctrl2;
wire cache_stall1,cache_stall2;
wire tagvalid1,tagvalid2;
wire s;
wire main_dmem_alt1;
wire main_dmem_alt2;
	 
pipeline_datapath pd1(.clk(clk),.rst(rst),.pc_enable(pc_enable),.instruction_address(instruction_address1),.instruction(instruction1),.instruction_write(instruction_write1),.thread(thread1),
.main_dmem_data(main_dmem_data),.main_dmem_address(main_dmem_address_1),.main_dmem_data_w(main_dmem_data_w_1),.main_dmem_address_w(main_dmem_address_w_1),.main_dmem_wen(main_dmem_wen_1),
.ctrl(ctrl1),.cache_stall(cache_stall1),.tagvalid(tagvalid1),.main_dmem_alt(main_dmem_alt1),.main_dmem_address_in(main_dmem_address_w));

pipeline_datapath pd2(.clk(clk),.rst(rst),.pc_enable(pc_enable),.instruction_address(instruction_address2),.instruction(instruction2),.instruction_write(instruction_write2),.thread(thread2),
.main_dmem_data(main_dmem_data),.main_dmem_address(main_dmem_address_2),.main_dmem_data_w(main_dmem_data_w_2),.main_dmem_address_w(main_dmem_address_w_2),.main_dmem_wen(main_dmem_wen_2),
.ctrl(ctrl2),.cache_stall(cache_stall2),.tagvalid(tagvalid2),.main_dmem_alt(main_dmem_alt2),.main_dmem_address_in(main_dmem_address_w));

control cu(.ctrl1(ctrl1),.ctrl2(ctrl2),.s(s),.tagvalid1(tagvalid1),.tagvalid2(tagvalid2),.cachestall1(cache_stall1),.cachestall2(cache_stall2),.main_dmem_alt1(main_dmem_alt1),.main_dmem_alt2(main_dmem_alt2));

mux2to1_data m1(.a(main_dmem_data_w_1),.b(main_dmem_data_w_2),.s(s),.c(main_dmem_data_w));

mux2to1_address m2(.a(main_dmem_address_w_1),.b(main_dmem_address_w_2),.s(s),.c(main_dmem_address_w));

mux2to1_address m3(.a(main_dmem_address_1),.b(main_dmem_address_2),.s(s),.c(main_dmem_address));

mux2to1_wen m4(.a(main_dmem_wen_1),.b(main_dmem_wen_2),.s(s),.c(main_dmem_wen));

main_dmem md(.clka(clk),.douta(main_dmem_data),.addra(main_dmem_address), .clkb(clk),.web(main_dmem_wen),.dinb(main_dmem_data_w),.addrb(main_dmem_address_w));
endmodule
