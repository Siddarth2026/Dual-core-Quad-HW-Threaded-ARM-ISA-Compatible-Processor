`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:53:45 06/04/2026 
// Design Name: 
// Module Name:    demux_address 
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
module demux_address(
    input [3:0] addr,
    input [1:0] thread,
    output reg [3:0] addr1,
    output reg [3:0] addr2,
    output reg [3:0] addr3,
    output reg [3:0] addr4
    );

always@(*)
begin
case (thread)
2'b00: begin addr1=addr;addr2=0;addr3=0;addr4=0; end
2'b01: begin addr2=addr;addr1=0;addr3=0;addr4=0; end
2'b10: begin addr3=addr;addr2=0;addr1=0;addr4=0; end
2'b11: begin addr4=addr;addr2=0;addr3=0;addr1=0; end
endcase
end
endmodule
