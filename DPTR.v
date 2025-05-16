`timescale 1ns/1ns

module DPTR(
    input clk,
    input reset,
    input wire [31:0] instruccion, 
    input wire [31:0] PC,
    input wire [31:0] PC_plus_4,
    output wire [31:0] resultadoALU,
    output wire [31:0] jump_address,
    output wire jump,
    output wire [31:0] next_PC
);

wire [31:0] r1, r2, r3, r5, r6, r7;
wire [8:0] out_control; 
wire [2:0] r4;
wire [31:0] imm_ext;
wire PCSrc;
wire [31:0] BranchAddr;
wire jal;



JumpAddressCalculator jump_calc(
    .PC_plus_4(PC_plus_4),
    .target_address(instruccion[25:0]),
    .jump_address(jump_address)
);

BR inst_BR(
    .clk(clk), 
    .adrsReadA(instruccion[25:21]), 
    .adrsReadB(instruccion[20:16]), 
    .adrsWrite(instruccion[15:11]), 
    .RegEn(out_control[8]), // RegWrite
    .write(jal ? PC_plus_4 : r1), // Para JAL, escribimos PC+4
    .readA(r2), 
    .readB(r3),
    .jal(out_control[0]) // JAL
);


DataMem inst_memoria(
    .address(r5), 
    .MemToWrite(out_control[5]), 
    .dataWrite(r3), 
    .dataRead(r7)
);


ALU inst_ALU(
    .A(r2), 
    .B(out_control[3] ? imm_ext : r3), // Mux para ALUSrc
    .Sel(r4), 
    .R(r5)
);


multiplexor inst_mux(
    .A_mux(r7), 
    .B_mux(r5), 
    .mux_sel(out_control[7]), 
    .salida_mux(r1)
);


Unidad_control inst_control(
    .OPcode(instruccion[31:26]), 
    .salida_control(out_control)
);


ALU_control inst_AluControl(
    .op(instruccion[5:0]), 
    .Op_in(out_control[6:4]), 
    .Op_out(r4)
);


SignExtend sign_ext(
    .imm(instruccion[15:0]), 
    .imm_ext(imm_ext)
);

// Lógica de salto
assign PCSrc = out_control[4] & ((r2 == r3)); // Branch (beq)
assign BranchAddr = PC_plus_4 + (imm_ext << 2);
assign jump = out_control[1]; // Jump
assign jal = out_control[0]; // JAL

assign resultadoALU = r5;

endmodule