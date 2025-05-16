`timescale 1ns / 1ps

module MIPS_Top(
    input clk,
    input reset,
    output wire [31:0] resultadoFinal  
);

// ==============================================
// ============ DECLARACIÓN DE WIRES ============
// ==============================================

// Etapa FETCH
wire [31:0] instr, PC_out, PC_in;

// Buffer IF/ID
wire [31:0] instr_IFID, PC_IFID;

// Etapa DECODE
wire [5:0] opcode;
wire [4:0] rs, rt, rd;
wire [15:0] imm;
wire [31:0] readA, readB, imm_ext;
wire [2:0] alu_op;
wire RegDst, Branch, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Jal;

// Buffer ID/EX
wire [31:0] PC_IDEX, RD1_IDEX, RD2_IDEX, SE_IDEX;
wire [4:0] rs_IDEX, rt_IDEX, rd_IDEX;
wire [7:0] control_IDEX;

// Etapa EXECUTE
wire [2:0] alu_ctrl;
wire [31:0] ALU_result;
wire [4:0] rd_final;
wire [31:0] muxB_to_alu;

// Buffer EX/MEM
wire [31:0] ALU_result_EXMEM, RD2_EXMEM;
wire [4:0] rd_EXMEM;
wire [3:0] control_EXMEM;

// Etapa MEM
wire [31:0] data_from_mem;

// Buffer MEM/WB
wire [31:0] MemReadData_MEMWB, ALU_result_MEMWB;
wire [4:0] rd_MEMWB;
wire [1:0] control_MEMWB;

// Etapa WRITE BACK
wire [31:0] write_back_data;
wire BR_write;
wire [4:0] BR_addr;
wire [31:0] BR_in;

// ==============================================
// ================ FASE: FETCH =================
// ==============================================

assign PC_in = PC_out + 32'd4;

PC pc_inst(
    .clk(clk),
    .reset(reset),
    .dataIn(PC_in),
    .dataOut(PC_out)
);

memoryInst mem_inst(
    .addrs(PC_out),
    .instruction(instr)
);

IF_ID_Reg if_id(
    .clk(clk),
    .inst_in(instr),
    .PC_plus_4_in(PC_out),
    .inst_out(instr_IFID),
    .PC_plus_4_out(PC_IFID)
);

// ==============================================
// ============== FASE: DECODE ==================
// ==============================================

assign opcode = instr_IFID[31:26];
assign rs = instr_IFID[25:21];
assign rt = instr_IFID[20:16];
assign rd = instr_IFID[15:11];
assign imm = instr_IFID[15:0];

Control control_unit(
    .opcode(opcode),
    .RegDst(RegDst),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemToReg),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jal(Jal),
    .ALUOp(alu_op[1:0])
);

BR reg_bank(
    .clk(clk),
    .adrsReadA(rs),
    .adrsReadB(rt),
    .adrsWrite(rd_MEMWB),  
    .RegEn(BR_write),
    .write(BR_in),
    .readA(readA),
    .readB(readB),
    .jal(Jal)
);

SignExtend se(
    .imm(imm),
    .imm_ext(imm_ext)
);

ID_EX_Reg id_ex(
    .clk(clk),
    .PC_in(PC_IFID),
    .RD1_in(readA),
    .RD2_in(readB),
    .SE_in(imm_ext),
    .rs_in(rs),
    .rt_in(rt),
    .rd_in(rd),
    .control_in({RegDst, Branch, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, Jal}), 
    .PC_out(PC_IDEX),
    .RD1_out(RD1_IDEX),
    .RD2_out(RD2_IDEX),
    .SE_out(SE_IDEX),
    .rs_out(rs_IDEX),
    .rt_out(rt_IDEX),
    .rd_out(rd_IDEX),
    .control_out(control_IDEX)
);

// ==============================================
// =============== FASE: EXECUTE ================
// ==============================================

// ALU Control
wire [5:0] funct = SE_IDEX[5:0];
ALU_control alu_control_unit(
    .op(funct),
    .Op_in(alu_op),
    .Op_out(alu_ctrl)
);

assign muxB_to_alu = (control_IDEX[2] == 1'b1) ? SE_IDEX : RD2_IDEX;

assign rd_final = control_IDEX[7] ? 5'd31 : (control_IDEX[6] ? rd_IDEX : rt_IDEX); 

// Unidad ALU
ALU alu(
    .A(RD1_IDEX),
    .B(muxB_to_alu),
    .Sel(alu_ctrl),
    .R(ALU_result)
);

// Buffer EX/MEM
EX_MEM_Reg ex_mem(
    .clk(clk),
    .ALU_result_in(ALU_result),
    .RD2_in(RD2_IDEX),
    .rd_in(rd_final),
    .control_in(control_IDEX[5:2]), // {MemRead, MemWrite, MemToReg, RegWrite}
    .ALU_result_out(ALU_result_EXMEM),
    .RD2_out(RD2_EXMEM),
    .rd_out(rd_EXMEM),
    .control_out(control_EXMEM)
);

// ==============================================
// ================ FASE: MEM ===================
// ==============================================

// Memoria de datos
DataMem data_mem(
    .address(ALU_result_EXMEM),
    .MemToWrite(control_EXMEM[2]), // MemWrite
    .dataWrite(RD2_EXMEM),
    .dataRead(data_from_mem)
);

// Buffer MEM/WB
MEM_WB_Reg mem_wb(
    .clk(clk),
    .MemReadData_in(data_from_mem),
    .ALU_result_in(ALU_result_EXMEM),
    .rd_in(rd_EXMEM),
    .control_in(control_EXMEM[1:0]), // {MemToReg, RegWrite}
    .MemReadData_out(MemReadData_MEMWB),
    .ALU_result_out(ALU_result_MEMWB),
    .rd_out(rd_MEMWB),
    .control_out(control_MEMWB)
);

// ==============================================
// ================== WB ========================
// ==============================================

// Mux MemToReg (ya declarado arriba)
assign write_back_data = control_MEMWB[1] ? MemReadData_MEMWB : ALU_result_MEMWB;  // MemToReg (bit 1)

// Conexiones al banco de registros
assign BR_in = write_back_data;
assign BR_addr = rd_MEMWB;
assign BR_write = control_MEMWB[0]; // RegWrite (bit 0) 

assign resultadoFinal = PC_out;
endmodule

module MIPS_Top_tb;

    reg clk;
    reg reset;
    wire [31:0] resultadoFinal;
    MIPS_Top uut(.clk(clk), .reset(reset), .resultadoFinal(resultadoFinal));

    initial begin
        clk = 0;
        reset = 1;  
        #10 reset = 0;

        $display("Tiempo\tPC\t\tInstr");
        $monitor("%0t\t%h\t%h", $time, uut.PC_out, uut.instr);  // Observa PC e instrucción actual

        #1000 begin
            $display("========== Fin de la simulación ==========");
            $display("PC final: %h", resultadoFinal);
            $finish;
        end
    end

    always #5 clk = ~clk;

endmodule
