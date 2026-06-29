`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:06:05 06/04/2026 
// Design Name: 
// Module Name:    demux_data 
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
module demux_data(
    input wen,
    input [63:0] wdata,
    input [1:0] thread,
    output reg wen1,
    output reg wen2,
    output reg wen3,
    output reg wen4,
    output reg [63:0] wdata1,
    output reg [63:0] wdata2,
    output reg [63:0] wdata3,
    output reg [63:0] wdata4
    );
always@(*)
begin
case(thread)
2'b00: begin wen1=wen; wen2=0; wen3=0; wen4=0; wdata1=wdata; wdata2=0; wdata3=0; wdata4=0;end
2'b01: begin wen2=wen; wen1=0; wen3=0; wen4=0; wdata2=wdata; wdata1=0; wdata3=0; wdata4=0;end
2'b10: begin wen3=wen; wen2=0; wen1=0; wen4=0; wdata3=wdata; wdata2=0; wdata1=0; wdata4=0;end
2'b11: begin wen4=wen; wen2=0; wen3=0; wen1=0; wdata4=wdata; wdata2=0; wdata3=0; wdata1=0;end
endcase
end

endmodule
