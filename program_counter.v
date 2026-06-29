module program_counter 
(
    input clk,
    input reset,
    input branch,
    input [31:0] branch_addr,
	 input pc_stall,
	 input pc_enable,
    output reg [31:0] pc
);

reg [31:0]pc_next;

always @(posedge clk) begin
    if(reset) begin
        pc <= 31'b0;

	 end
	 else if(pc_stall)
	 begin
	 pc<=pc;
	 end
    else if(pc_enable)
	 begin
        pc <= pc_next;
    end
    
end

always@(*)
begin
pc_next = (branch) ? branch_addr : (pc + 4);
end
endmodule

