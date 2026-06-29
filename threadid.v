`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:28:37 06/03/2026 
// Design Name: 
// Module Name:    threadid 
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
module threadid(
    input pc_enable,
	 output reg [1:0] current,
	 input reset,
	 input clk
    );
	 
reg [1:0] next;

always@(posedge clk)
begin
if(reset)
begin
current<=2'b0;
end
else if(pc_enable)
begin
current<=next;
end
end

always@(*)
begin
if(pc_enable)
next=current+1;
end
endmodule
