`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:18:45 05/21/2026 
// Design Name: 
// Module Name:    HDU 
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
module HDU(
    input [3:0] wreg_addr_stage3,
    input [3:0] wreg_addr_stage4,
	 input [3:0] wreg_addr_stage5,
	 input [3:0] wreg_addr_stage6,
    input [3:0] reg1_addr_stage2,
    input [3:0] reg2_addr_stage2,
	 input wregen_stage3,
	 input wregen_stage4,
	 input wregen_stage5,	 
	 input wregen_stage6,
	 input control,
	 input [1:0] thread_ID,
	 input [1:0] thread_EX,
	 input [1:0] thread_MEM1,
	 input [1:0] thread_MEM2,
	 input [1:0] thread_WB,
    output stall
    );
wire s1,s2,s3,s4,s5,s6;

assign s1=(wreg_addr_stage3==reg1_addr_stage2)&wregen_stage3&(thread_ID==thread_EX);
assign s2=(wreg_addr_stage3==reg2_addr_stage2)&wregen_stage3&(thread_ID==thread_EX);
assign s3=(wreg_addr_stage4==reg1_addr_stage2)&wregen_stage4&(thread_ID==thread_MEM1);
assign s4=(wreg_addr_stage4==reg2_addr_stage2)&wregen_stage4&(thread_ID==thread_MEM1);
assign s5=(wreg_addr_stage5==reg1_addr_stage2)&wregen_stage5&(thread_ID==thread_MEM2);
assign s6=(wreg_addr_stage5==reg2_addr_stage2)&wregen_stage5&(thread_ID==thread_MEM2);
assign s7=(wreg_addr_stage6==reg1_addr_stage2)&wregen_stage6&(thread_ID==thread_WB);
assign s8=(wreg_addr_stage6==reg2_addr_stage2)&wregen_stage6&(thread_ID==thread_WB);

assign stall=(s1|s2|s3|s4|s5|s6|s7|s8)&control;

endmodule
