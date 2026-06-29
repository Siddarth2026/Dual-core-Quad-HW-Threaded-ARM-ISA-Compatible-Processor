`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:35:31 05/22/2026 
// Design Name: 
// Module Name:    FU 
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
module FU(
    input [3:0] reg1_addr_stage3,
    input [3:0] reg2_addr_stage3,
    input [3:0] wreg_addr_stage4,
    input [3:0] wreg_addr_stage5,
    input [3:0] wreg_addr_stage6,
    output reg [1:0] s1,
    output reg [1:0] s2,
    input wregen_stage4,
    input wregen_stage5,
    input wregen_stage6,
	 input [1:0] thread_EX,
	 input [1:0] thread_MEM1,
	 input [1:0] thread_MEM2,
	 input [1:0] thread_WB
    );
always@(*)
begin
if((wreg_addr_stage4==reg1_addr_stage3)&&wregen_stage4&&(thread_EX==thread_MEM1))
s1=2'b01;
else if ((wreg_addr_stage5==reg1_addr_stage3)&&wregen_stage5&&(thread_EX==thread_MEM2))
s1=2'b10;
else if ((wreg_addr_stage6==reg1_addr_stage3)&&wregen_stage6&&(thread_EX==thread_WB))
s1=2'b11;
else
s1=2'b00;

if((wreg_addr_stage4==reg2_addr_stage3)&&wregen_stage4&&(thread_EX==thread_MEM1))
s2=2'b01;
else if ((wreg_addr_stage5==reg2_addr_stage3)&&wregen_stage5&&(thread_EX==thread_MEM2))
s2=2'b10;
else if ((wreg_addr_stage6==reg2_addr_stage3)&&wregen_stage6&&(thread_EX==thread_WB))
s2=2'b11;
else
s2=2'b00;
end

endmodule
