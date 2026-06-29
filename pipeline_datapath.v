`timescale 1ns / 1ps
module pipeline_datapath(
    input clk,
    input rst,
	 input pc_enable,
	 input [7:0]instruction_address,
	 input [31:0]instruction,
	 input instruction_write,
	 output [1:0] thread,
	 input [63:0] main_dmem_data,
	 output [11:0] main_dmem_address,
	 output [63:0] main_dmem_data_w,
	 output [11:0] main_dmem_address_w,
	 output main_dmem_wen,
	 output [1:0]ctrl,
	 input cache_stall,
	 input tagvalid,
	 input main_dmem_alt,
	 input main_dmem_address_in
);

//============================================================================
//  Thread ID, PC and Instruction memory - Srage 1
//============================================================================
wire [31:0] pc;
wire [31:0] pc1,pc2,pc3,pc4;
reg branch_stage3;
wire branch_taken;
wire [31:0] branch_addr;
reg [31:0]branch_addr_stage3;
wire stall;
wire [1:0]current_thread;
reg [1:0]current_thread_stage2,current_thread_stage3,current_thread_stage4,current_thread_stage5;

//Thread ID
threadid tid(.pc_enable(pc_enable),.reset(rst),.clk(clk),.current(current_thread));

//Program Counter
program_counter pc_inst1(.clk(clk),.reset(rst),.branch(branch_taken&(current_thread_stage2==2'b00)),.branch_addr(branch_addr),.pc(pc1), .pc_stall(stall),.pc_enable(pc_enable));
program_counter pc_inst2(.clk(clk),.reset(rst),.branch(branch_taken&(current_thread_stage2==2'b01)),.branch_addr(branch_addr),.pc(pc2), .pc_stall(stall),.pc_enable(pc_enable));
program_counter pc_inst3(.clk(clk),.reset(rst),.branch(branch_taken&(current_thread_stage2==2'b10)),.branch_addr(branch_addr),.pc(pc3), .pc_stall(stall),.pc_enable(pc_enable));
program_counter pc_inst4(.clk(clk),.reset(rst),.branch(branch_taken&(current_thread_stage2==2'b11)),.branch_addr(branch_addr),.pc(pc4), .pc_stall(stall),.pc_enable(pc_enable));
mux4to1 m1(.pc1(pc1),.pc2(pc2),.pc3(pc3),.pc4(pc4),.select(current_thread),.pc(pc));


wire [7:0]addra=pc[9:2];
assign thread=current_thread;

wire [31:0] instruction_r;
reg [31:0] instruction_stage2;


imem1 imem1 (
    .clka(clk),                    
    .addra(addra),              
    .douta(instruction_r),
	 .clkb(clk),
	 .web(instruction_write),
	 .addrb(instruction_address),
	 .dinb(instruction),
	 .ena(~(stall))
);
//============================================================================
//  PIPELINE DELAY REGISTER 1 (Stage 1 to 2)
//============================================================================
always@(posedge clk)
begin
if(rst)
begin
instruction_stage2<=32'h0;
current_thread_stage2<=2'b0;
end
else begin 
if(stall|cache_stall)
begin
instruction_stage2<=instruction_stage2;
current_thread_stage2<=current_thread_stage2;
end
else
begin
instruction_stage2<=instruction_r;
current_thread_stage2<=current_thread;
end
end
end
////============================================================================
//  Control Unit - Stage 2
//============================================================================

// control  unit 
// instruction fields
wire [3:0] inst_cond = instruction_stage2[31:28]; //Condition Bits
// opcode is bits 27-20
wire [7:0] inst_cu = instruction_stage2[27:20]; //Opcode Bits
// register addresses
wire [3:0] wreg_addr_stage2;
// reg1 is bits 15-12, reg2 is bits 3-0
wire [3:0] reg1_addr_stage2;
wire [3:0] reg2_addr_stage2;

//Control signals
wire [1:0] aluOp;
wire aluSrc;
wire branch;
wire memWrite;
wire regWrite;
wire memtoReg;
wire [4:0] cmd;
wire regDst;

control_unit cu_inst(
    .inst27_20(inst_cu),
    .regDst(regDst),
    .aluOp(aluOp),
    .aluSrc(aluSrc),
    .branch(branch),
    .memWrite(memWrite),
    .regWrite(regWrite),
    .memtoReg(memtoReg),
    .cmd(cmd)
);

wire set=instruction_stage2[20];
wire [3:0] nzcv_flags_reg;
reg condition_met;

reg [3:0]nzcv_flags_ALU_thread1,nzcv_flags_ALU_thread2,nzcv_flags_ALU_thread3,nzcv_flags_ALU_thread4;

assign nzcv_flags_reg = (current_thread_stage2==2'b00)?(nzcv_flags_ALU_thread1):
								(current_thread_stage2==2'b01)?(nzcv_flags_ALU_thread2):
								(current_thread_stage2==2'b10)?(nzcv_flags_ALU_thread3):
								(current_thread_stage2==2'b11)?(nzcv_flags_ALU_thread4):4'b0; // Update the registered NZCV flags with the latest ALU output flags at the end of each cycle
always@(*)
case(inst_cond)
    //NZCV
    4'b0000: condition_met = (nzcv_flags_reg[2]==1'b1)?1:0; // EQ: Z=1
    4'b0001: condition_met = (nzcv_flags_reg[2]==1'b0)?1:0; // NE: Z=0
    4'b0010: condition_met = (nzcv_flags_reg[1]==1'b1)?1:0; // CS/HS: C=1
    4'b0011: condition_met = (nzcv_flags_reg[1]==1'b0)?1:0; // CC/LO: C=0
    4'b0100: condition_met = (nzcv_flags_reg[3]==1'b1)?1:0; // MI: N=1
    4'b0101: condition_met = (nzcv_flags_reg[3]==1'b0)?1:0; // PL: N=0
    4'b0110: condition_met = (nzcv_flags_reg[0]==1'b1)?1:0; // VS: V=1
    4'b0111: condition_met = (nzcv_flags_reg[0]==1'b0)?1:0; // VC: V=0
    4'b1000: condition_met = (nzcv_flags_reg[1]==1'b1 && nzcv_flags_reg[2]==1'b0)?1:0; // HI: C=1 and Z=0  
    4'b1001: condition_met = (nzcv_flags_reg[1]==1'b0 || nzcv_flags_reg[2]==1'b1)?1:0; // LS: C=0 or Z=1 
    4'b1010: condition_met = (nzcv_flags_reg[0]==nzcv_flags_reg[3])?1:0; // GE: N==V 
    4'b1011: condition_met = (nzcv_flags_reg[0]!=nzcv_flags_reg[3])?1:0; // LT: N!=V 
    4'b1100: condition_met = ((nzcv_flags_reg[2]==1'b0) && (nzcv_flags_reg[3]==nzcv_flags_reg[0]))?1:0; // GT: Z=0 and N=V
    4'b1101: condition_met = ((nzcv_flags_reg[2]==1'b1) || (nzcv_flags_reg[3]!=nzcv_flags_reg[0]))?1:0; // LE: Z=1 or N!=V
    4'b1110: condition_met = 1'b1; // AL (1110): always
    4'b1111: condition_met = 1'b0; // NV (1111): never
endcase
wire [1:0] type_stage2 = instruction_stage2[27:26];
wire [4:0] shft_amt = instruction_stage2[11:7];
wire [31:0] se_offset;
//If type is 2'b10 for Branch, sign extend the 24-bit offset and shift left by 2, 
//If type is 2'b01 for LW/SW, sign extend the 12-bit offset and shift left by 2 
//Sign extend for immediate value.
assign se_offset = (type_stage2 == 2'b10) ?
						 {{6{instruction_stage2[23]}}, instruction_stage2[23:0], 2'b00}:((type_stage2 == 2'b01)?
						 {{18{instruction_stage2[11]}}, instruction_stage2[11:0],2'b00}:{{20{instruction_stage2[11]}}, instruction_stage2[11:0]});


assign branch_addr = pc + 32'd0 + se_offset;
assign branch_taken = branch && condition_met;
//============================================================================
// Hazard Detection Unit
//============================================================================

reg [1:0]current_thread_stage6;
reg regWrite_stage6;
reg regWrite_stage5;
reg [3:0] wreg_addr_stage4; 
reg [3:0] wreg_addr_stage3; 
reg regWrite_stage3;
reg regWrite_stage4;
reg memtoReg_stage3;
reg [3:0] wreg_addr_stage5;
reg [3:0] wreg_addr_stage6;

HDU hdu(.wreg_addr_stage3(wreg_addr_stage3),.wreg_addr_stage4(wreg_addr_stage4),.wreg_addr_stage5(wreg_addr_stage5),.wreg_addr_stage6(wreg_addr_stage6),
.reg1_addr_stage2(reg1_addr_stage2),.reg2_addr_stage2(reg2_addr_stage2),
.wregen_stage3(regWrite_stage3),.wregen_stage4(regWrite_stage4),.wregen_stage5(regWrite_stage5),.wregen_stage6(regWrite_stage6),.stall(stall),.control(memtoReg_stage3),
.thread_ID(current_thread_stage2),.thread_EX(current_thread_stage3),.thread_MEM1(current_thread_stage4),.thread_MEM2(current_thread_stage5),.thread_WB(current_thread_stage6));

//HDU altered for Multithread

//============================================================================
// REGISTER FILE
//============================================================================

assign wreg_addr_stage2 = instruction_stage2[15:12];
assign reg1_addr_stage2 = instruction_stage2[19:16];
assign reg2_addr_stage2 =(regDst == 1)?instruction_stage2[3:0]:instruction_stage2[15:12];


wire [63:0] reg1_data;  
wire [63:0] reg2_data;  
wire [63:0] wData_stage5;
wire [63:0] wData_stage6;

wire [3:0] reg1_addr_stage2_1;
wire [3:0] reg1_addr_stage2_2;
wire [3:0] reg1_addr_stage2_3;
wire [3:0] reg1_addr_stage2_4;

wire [3:0] reg2_addr_stage2_1;
wire [3:0] reg2_addr_stage2_2;
wire [3:0] reg2_addr_stage2_3;
wire [3:0] reg2_addr_stage2_4;

wire [3:0] wreg_addr_stage5_1;
wire [3:0] wreg_addr_stage5_2;
wire [3:0] wreg_addr_stage5_3;
wire [3:0] wreg_addr_stage5_4;

wire [63:0] wData_stage5_1;
wire [63:0] wData_stage5_2;
wire [63:0] wData_stage5_3;
wire [63:0] wData_stage5_4;

wire [63:0] reg1_data_1;  
wire [63:0] reg2_data_1; 
wire [63:0] reg1_data_2;  
wire [63:0] reg2_data_2;
wire [63:0] reg1_data_3;  
wire [63:0] reg2_data_3;
wire [63:0] reg1_data_4;  
wire [63:0] reg2_data_4;



//Demux for writing and reading from the 4 register files
demux_address r0(.addr(reg1_addr_stage2),.thread(current_thread_stage2),.addr1(reg1_addr_stage2_1),.addr2(reg1_addr_stage2_2),.addr3(reg1_addr_stage2_3),.addr4(reg1_addr_stage2_4));
demux_address r1(.addr(reg2_addr_stage2),.thread(current_thread_stage2),.addr1(reg2_addr_stage2_1),.addr2(reg2_addr_stage2_2),.addr3(reg2_addr_stage2_3),.addr4(reg2_addr_stage2_4));
demux_address wa(.addr(wreg_addr_stage6),.thread(current_thread_stage6),.addr1(wreg_addr_stage5_1),.addr2(wreg_addr_stage5_2),.addr3(wreg_addr_stage5_3),.addr4(wreg_addr_stage5_4));
demux_data wd(.wen(regWrite_stage6),.wdata(wData_stage6),.thread(current_thread_stage6),.wen1(regWrite_stage5_1),.wen2(regWrite_stage5_2),.wen3(regWrite_stage5_3),.wen4(regWrite_stage5_4),.wdata1(wData_stage5_1),.wdata2(wData_stage5_2),.wdata3(wData_stage5_3),.wdata4(wData_stage5_4));

register_file regfile1 (
    .clk(clk),
    .rst(rst),                      
    .r0addr(reg1_addr_stage2_1),             
    .r1addr(reg2_addr_stage2_1),             
    .waddr(wreg_addr_stage5_1),       
    .wdata(wData_stage5_1),              
    .wena(regWrite_stage5_1),          
	 .pc(pc1),
    .r0data(reg1_data_1),             
    .r1data(reg2_data_1)             
);

register_file regfile2 (
    .clk(clk),
    .rst(rst),                      
    .r0addr(reg1_addr_stage2_2),             
    .r1addr(reg2_addr_stage2_2),             
    .waddr(wreg_addr_stage5_2),       
    .wdata(wData_stage5_2),              
    .wena(regWrite_stage5_2),          
	 .pc(pc2),
    .r0data(reg1_data_2),             
    .r1data(reg2_data_2)             
);

register_file regfile3 (
    .clk(clk),
    .rst(rst),                      
    .r0addr(reg1_addr_stage2_3),             
    .r1addr(reg2_addr_stage2_3),             
    .waddr(wreg_addr_stage5_3),       
    .wdata(wData_stage5_3),              
    .wena(regWrite_stage5_3),          
	 .pc(pc3),
    .r0data(reg1_data_3),             
    .r1data(reg2_data_3)             
);

register_file regfile4 (
    .clk(clk),
    .rst(rst),                      
    .r0addr(reg1_addr_stage2_4),             
    .r1addr(reg2_addr_stage2_4),             
    .waddr(wreg_addr_stage5_4),       
    .wdata(wData_stage5_4),              
    .wena(regWrite_stage5_4),          
	 .pc(pc4),
    .r0data(reg1_data_4),             
    .r1data(reg2_data_4)             
);

//Mux to read from the register file
mux_data rd0(.data1(reg1_data_1),.data2(reg1_data_2),.data3(reg1_data_3),.data4(reg1_data_4),.thread(current_thread_stage2),.data(reg1_data));
mux_data rd1(.data1(reg2_data_1),.data2(reg2_data_2),.data3(reg2_data_3),.data4(reg2_data_4),.thread(current_thread_stage2),.data(reg2_data));



wire [63:0] reg1_data_update;

assign reg1_data_update = (cmd[4:1] == 4'b1101) ? {{59{1'b0}},shft_amt}: reg1_data;

//============================================================================
//  PIPELINE DELAY REGISTER 2 (Stage 2 to 3) ( To dummy)
//============================================================================


reg [3:0] reg1_addr_stage3;
reg [3:0] reg2_addr_stage3;
reg [63:0]reg1_data_stage3;
reg [63:0]reg2_data_stage3;
reg [31:0]se_offset_stage3;
reg [3:0] nzcv_flags_stage3;
reg [1:0] aluOp_stage3;
reg aluSrc_stage3;
reg memWrite_stage3;
reg [4:0] cmd_stage3;


always @(posedge clk) begin
    if (rst) begin
        wreg_addr_stage3 <= 4'b0;
		  reg1_addr_stage3 <= 4'b0;
        reg2_addr_stage3 <= 4'b0;
        reg1_data_stage3 <= 64'b0;
        reg2_data_stage3 <= 64'b0;
        branch_addr_stage3<=32'b0;
        se_offset_stage3<=32'b0;
        nzcv_flags_stage3 <= 4'b0;
        aluOp_stage3 <= 2'b0;
        aluSrc_stage3 <= 0;
        branch_stage3 <= 0;
        memWrite_stage3 <= 0;
        memtoReg_stage3 <= 0;
        regWrite_stage3 <= 0;
        cmd_stage3 <= 5'b0;
		  current_thread_stage3<=2'b0;
    end 
    else if (branch_taken|stall) begin                          
        wreg_addr_stage3 <= 4'b0;
		  reg1_addr_stage3 <= 4'b0;
        reg2_addr_stage3 <= 4'b0;
        reg1_data_stage3 <= 64'b0;
        reg2_data_stage3 <= 64'b0;
        se_offset_stage3<=32'b0;
        nzcv_flags_stage3 <= 4'b0;
        aluOp_stage3 <= 2'b0;
        aluSrc_stage3 <= 0;
        branch_stage3 <= 0;
        memWrite_stage3 <= 0;
        memtoReg_stage3 <= 0;
        regWrite_stage3 <= 0;
        cmd_stage3 <= 5'b0;
		  current_thread_stage3<=2'b0;
    end
	 else if(cache_stall)
	 begin
	 wreg_addr_stage3 <= wreg_addr_stage3;
		  reg1_addr_stage3 <= reg1_addr_stage3;
        reg2_addr_stage3 <= reg2_addr_stage3;
        reg1_data_stage3 <= reg1_data_stage3;
        reg2_data_stage3 <= reg2_data_stage3;
        branch_stage3<=branch_stage3;
        branch_addr_stage3<=branch_addr_stage3;
        se_offset_stage3<=se_offset_stage3;
        aluOp_stage3 <= aluOp_stage3;
        aluSrc_stage3 <= aluSrc_stage3;
        memWrite_stage3 <= memWrite_stage3;
        memtoReg_stage3 <= memtoReg_stage3;
        regWrite_stage3 <= regWrite_stage3;
        cmd_stage3 <= cmd_stage3;
        nzcv_flags_stage3 <= nzcv_flags_stage3;
		  current_thread_stage3<=current_thread_stage3;
	 end
    else begin
        wreg_addr_stage3 <= wreg_addr_stage2;
		  reg1_addr_stage3 <= reg1_addr_stage2;
        reg2_addr_stage3 <= reg2_addr_stage2;
        reg1_data_stage3 <= reg1_data_update;
        reg2_data_stage3 <= reg2_data;
        branch_stage3<=branch_taken;
        branch_addr_stage3<=branch_addr;
        se_offset_stage3<=se_offset;
        aluOp_stage3 <= aluOp;
        aluSrc_stage3 <= aluSrc;
        memWrite_stage3 <= memWrite;
        memtoReg_stage3 <= memtoReg;
        regWrite_stage3 <= regWrite;
        cmd_stage3 <= cmd;
        nzcv_flags_stage3 <= nzcv_flags_reg;
		  current_thread_stage3<=current_thread_stage2;
    end
end
//============================================================================
//  Execution Stage - Stage 3
//============================================================================

wire [1:0]s1,s2;
reg [63:0] aludata_stage4;
reg [63:0] aludata_stage5;

//FU altered for multithreading
FU fu(.reg1_addr_stage3(reg1_addr_stage3),
    .reg2_addr_stage3(reg2_addr_stage3),
	 .wreg_addr_stage4(wreg_addr_stage4),
    .wreg_addr_stage5(wreg_addr_stage5),
    .wreg_addr_stage6(wreg_addr_stage6),
    .s1(s1),
    .s2(s2),
    .wregen_stage4(regWrite_stage4),
    .wregen_stage5(regWrite_stage5),	 
    .wregen_stage6(regWrite_stage6),
	 .thread_EX(current_thread_stage3),.thread_MEM1(current_thread_stage4),.thread_MEM2(current_thread_stage5),.thread_WB(current_thread_stage6));
	 
	 
wire [63:0] reg1_data_stage3_fw,reg2_data_stage3_fw;

FMP fmp1(.regdata(reg1_data_stage3),
    .S1data(aludata_stage4),
	 .S2data(aludata_stage5),
    .S3data(wData_stage6),
    .select(s1),
	 .fmout(reg1_data_stage3_fw));

FMP fmp2(.regdata(reg2_data_stage3),
    .S1data(aludata_stage4),
    .S2data(aludata_stage5),
    .S3data(wData_stage6),
    .select(s2),
	 .fmout(reg2_data_stage3_fw));


wire [63:0]ALU_leg1 = reg1_data_stage3_fw;
// if aluSrc is 1, ALU_leg2 is the sign-extended offset, else ALU_leg2 is reg2 data

wire [63:0]ALU_leg2 = aluSrc_stage3?({{32{se_offset_stage3[31]}},se_offset_stage3}):(reg2_data_stage3_fw);

wire [3:0]flagout;
// stored NZCV flags register: [3]=N [2]=Z [1]=C [0]=V, updated by S-bit instructions

wire [63:0] aludata;
// A_next is the post-indexed base register writeback address for LDR/STR
wire [63:0] alu_base_writeback;
//A-next = branch_addr_stage3 if branch, else A-next = A

ALU alu(.opcode_initial(cmd_stage3),.A(ALU_leg1),.B(ALU_leg2),.ALU_op(aluOp_stage3),
.A_next(alu_base_writeback),.result(aludata),.flag_in(nzcv_flags_stage3),.flag_out(flagout));

always@(posedge clk)
begin
if(rst)
begin
nzcv_flags_ALU_thread1<=0;
nzcv_flags_ALU_thread2<=0;
nzcv_flags_ALU_thread3<=0;
nzcv_flags_ALU_thread4<=0;
end
else
begin
case(current_thread_stage3)
2'b00:nzcv_flags_ALU_thread1<=flagout;
2'b01:nzcv_flags_ALU_thread2<=flagout;
2'b10:nzcv_flags_ALU_thread3<=flagout;
2'b11:nzcv_flags_ALU_thread4<=flagout;
endcase
end
end


//============================================================================
//  PIPELINE DELAY REGISTER 3 (Stage 3 to 4)
//============================================================================


reg [63:0]reg1_data_stage4;
reg [63:0]reg2_data_stage4;

reg memWrite_stage4;
reg memtoReg_stage4;

always @(posedge clk) begin
    if (rst) begin
       wreg_addr_stage4 <= 4'b0;
	    reg1_data_stage4 <= 64'b0;
	    reg2_data_stage4 <= 64'b0;

    // control signals
        memWrite_stage4 <= 0;
        memtoReg_stage4 <= 0;
        regWrite_stage4 <= 0;
		  current_thread_stage4<=0;

    // alu data
        aludata_stage4 <= 64'b0;
    end
	 else if(cache_stall)
	 begin
	 wreg_addr_stage4 <= wreg_addr_stage4;
	    reg1_data_stage4 <= reg1_data_stage4;
	    reg2_data_stage4 <= reg2_data_stage4;
		 current_thread_stage4<=current_thread_stage4;

    // control signals
        memWrite_stage4 <= memWrite_stage4;
        memtoReg_stage4 <= memtoReg_stage4;
        regWrite_stage4 <= regWrite_stage4;

    // alu
        aludata_stage4 <= aludata_stage4;
	 end
	 else begin
        wreg_addr_stage4 <= wreg_addr_stage3;
	    reg1_data_stage4 <= reg1_data_stage3_fw;
	    reg2_data_stage4 <= reg2_data_stage3_fw;
		 current_thread_stage4<=current_thread_stage3;

    // control signals
        memWrite_stage4 <= memWrite_stage3;
        memtoReg_stage4 <= memtoReg_stage3;
        regWrite_stage4 <= regWrite_stage3;

    // alu
        aludata_stage4 <= aludata;
    end
end

//============================================================================
// DATA CACHE MEMORY (DMEM) - Stage 4
//============================================================================
wire [63:0] dmemData;
wire [3:0] tag;
wire cache_hit;
wire [63:0] cache_data;



reg main_dmem_start;
reg main_dmem_wb;
reg [11:0] main_dmem_address_stage6;

wire [8:0] tag_mem_address;
wire tag_mem_we;
assign tag_mem_address=(main_dmem_alt)?main_dmem_address_in:main_dmem_address_stage6;
assign tag_mem_we=main_dmem_alt|main_dmem_wb;

tagram tram(//Cache
				.clka(clk),
				.wea(memWrite_stage4),
				.dina({1'b1,aludata_stage4[13:11]}),
				.addra(aludata_stage4[10:2]),
				.douta(tag),
				//Main memory ports
				.clkb(clk),
				.addrb(tag_mem_address[8:0]),
				.web(tag_mem_we),
				.dinb({tagvalid,tag_mem_address[11:9]}));


dmem dmem1 (
//Cache ports
    .clka(clk),                     // Port A clock
    .wea(memWrite_stage4),           // Write enable
    .addra(aludata_stage4[10:2]),         // Address from Register 1 (9 bits for 512 depth)
    .dina(reg2_data_stage4),               // Write data from Register 2
    .douta(cache_data),         // Read data output
	 
//Main memory interaction ports
    .clkb(clk),
    .addrb(main_dmem_address_stage6[8:0]),
	 .web(main_dmem_wb),
	 .dinb(main_dmem_data)
);
//============================================================================
//  PIPELINE DELAY REGISTER 4 (Stage 4 to 5)
//============================================================================
reg memtoReg_stage5;
reg [63:0]reg2_data_stage5;
reg memWrite_stage5;

always@(posedge clk)
begin
if(rst)
begin
wreg_addr_stage5 <= 4'b0;
memtoReg_stage5 <= 0;
regWrite_stage5 <= 0;
aludata_stage5 <= 64'b0;
current_thread_stage5<=0;
memWrite_stage5<=0;
reg2_data_stage5<=64'b0;
end
else if (cache_stall) begin
wreg_addr_stage5 <= wreg_addr_stage5;
memtoReg_stage5 <= memtoReg_stage5;
regWrite_stage5 <= regWrite_stage5;
aludata_stage5 <= aludata_stage5;
current_thread_stage5<=current_thread_stage5;
memWrite_stage5<=memWrite_stage5;
reg2_data_stage5<=reg2_data_stage5;
end
else begin
wreg_addr_stage5 <= wreg_addr_stage4;
memtoReg_stage5 <= memtoReg_stage4;
regWrite_stage5 <= regWrite_stage4;
aludata_stage5 <= aludata_stage4;
current_thread_stage5<=current_thread_stage4;
memWrite_stage5<=memWrite_stage4;
reg2_data_stage5<=reg2_data_stage4;
end
end


//============================================================================
// DATA MAIN MEMORY (DMEM) - Stage 5
//============================================================================

assign cache_hit=tag[3]&(tag[2:0]==aludata_stage5[13:11]);
assign main_dmem_wen=memWrite_stage5;
assign main_dmem_address_w=aludata_stage5[13:2];
assign main_dmem_address=aludata_stage5[13:2];
assign main_dmem_data_w=reg2_data_stage5;
wire cache_miss;
assign cache_miss=((~cache_hit)&memtoReg_stage5);


assign ctrl={cache_miss,main_dmem_wen}; //read=bit0,write=bit1

//main_dmem md(.clka(clk),.douta(main_dmem_data),.addra(main_dmem_address), .clkb(clk),.web(main_dmem_wen),.dinb(main_dmem_data_w),.addrb(main_dmem_address_w));


//============================================================================
//  PIPELINE DELAY REGISTER 5 (Stage 5 to 6)
//============================================================================

reg memtoReg_stage6;
reg [63:0] aludata_stage6;
reg cachemiss_stage6;
reg [63:0]cache_data_stage6;

always @(posedge clk) begin               
    if (rst) begin
        wreg_addr_stage6 <= 4'b0;
        memtoReg_stage6 <= 0;
        regWrite_stage6 <= 0;
        aludata_stage6 <= 64'b0;
		  current_thread_stage6<=0;
		  cachemiss_stage6<=0;
		  cache_data_stage6<=64'h0;
		  main_dmem_wb<=1'b0;
		  main_dmem_address_stage6<=12'b0;

    end else begin
        wreg_addr_stage6 <= wreg_addr_stage5;
        memtoReg_stage6 <= memtoReg_stage5;
        regWrite_stage6 <= regWrite_stage5;
        aludata_stage6 <= aludata_stage5;
		  current_thread_stage6<=current_thread_stage5;
		  cachemiss_stage6<=cache_miss;
		  cache_data_stage6<=cache_data;
		  main_dmem_wb<=cache_miss;
		  main_dmem_address_stage6<=main_dmem_address;
    end
end

//============================================================================
// 7. WRITEBACK - Memory output to Register File
//============================================================================
assign dmemData=(cachemiss_stage6)?(main_dmem_data):(cache_data_stage6);

assign wData_stage6 =(memtoReg_stage6)?(dmemData):(aludata_stage6);
endmodule