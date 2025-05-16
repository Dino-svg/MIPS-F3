`timescale 1ns/1ns

module Unidad_control(
    input wire [5:0] OPcode,
    output reg [8:0] salida_control 
);
    // Bit 8: RegWrite
    // Bit 7: MemtoReg
    // Bit 6: MemRead
    // Bit 5: MemWrite
    // Bit 4: Branch
    // Bit 3: ALUSrc
    // Bit 2: RegDst
    // Bit 1: Jump
    // Bit 0: JAL

    always @(*) begin
        case (OPcode)
            6'b000000: salida_control = 9'b1_1_0_0_0_0_1_0_0; // Tipo R
            6'b100011: salida_control = 9'b1_0_1_0_0_1_0_0_0; // lw
            6'b101011: salida_control = 9'b0_0_0_1_0_1_0_0_0; // sw
            6'b000100: salida_control = 9'b0_0_0_0_1_0_0_0_0; // beq
            6'b000010: salida_control = 9'b0_0_0_0_0_0_0_1_0; // j
            6'b000011: salida_control = 9'b1_0_0_0_0_0_0_1_1; // jal
            default:   salida_control = 9'b0_0_0_0_0_0_0_0_0;
        endcase
    end
endmodule

