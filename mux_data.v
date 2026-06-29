`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:01:25 06/04/2026 
// Design Name: 
// Module Name:    mux_data 
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
module mux_data(
    input [63:0] data1,
    input [63:0] data2,
    input [63:0] data3,
    input [63:0] data4,
    input [1:0] thread,
    output reg [63:0] data
    );
always@(*)
begin
case (thread)
2'b00:data=data1;
2'b01:data=data2;
2'b10:data=data3;
2'b11:data=data4;
endcase
end

endmodule
