`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:26 06/21/2026 
// Design Name: 
// Module Name:    control 
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
module control(
    input [1:0] ctrl1,
    input [1:0] ctrl2,
    output s,
    output tagvalid1,
    output tagvalid2,
    output cachestall1,
    output cachestall2,
	 output main_dmem_alt1,
	 output main_dmem_alt2
    );

assign s=(|ctrl2)&(~|ctrl1); //pd2 needs memory and pd1 doesn't.pd1 will always have the priority.
assign tagvalid1=ctrl1[1]&(~s); //pd1 has a cache miss and has access.
assign tagvalid2=ctrl2[1]&s; //pd2 has a cache miss and has access.
assign cachestall1=|ctrl1&(s); //when pd1 needs memory and has no access.Ideally would be 1'b0.
assign cachestall2=|ctrl2&(~s); //when pd2 needs memory and has no access.
assign main_dmem_alt1=ctrl2[0]&s; //pd2 wants to write and has permission.
assign main_dmem_alt2=ctrl1[0]&(~s); //pd1 wants to write and has permission.
endmodule
