`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:12 06/20/2026 
// Design Name: 
// Module Name:    mux2to1_address 
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
module mux2to1_address(
    input [11:0] a,
    input [11:0] b,
    input s,
    output [11:0] c
    );

assign c=s?b:a;
endmodule
