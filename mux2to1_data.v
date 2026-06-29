`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:47:55 06/20/2026 
// Design Name: 
// Module Name:    mux2to1_data 
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
module mux2to1_data(
    input [63:0] a,
    input [63:0] b,
    input s,
    output [63:0] c
    );

assign c=s?b:a;
endmodule
