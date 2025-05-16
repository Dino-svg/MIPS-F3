`timescale 1ns/1ns

module Fetch(
    input clkF,
    input reset,
    input [31:0] jump_address,
    input jump,
    output [31:0] instructionF,
    output [31:0] PC_plus_4,
    output [31:0] PC,
    output [31:0] next_PC
);

wire [31:0] In_Wire, Out_Wire;
wire [31:0] inst_Wire;

// Mux para selección de next_PC (Jump o PC+4)
assign next_PC = jump ? jump_address : PC_plus_4;

SUM add(.addrs(Out_Wire), .addrsOut(PC_plus_4));
PC pc(.dataIn(next_PC), .clk(clkF), .reset(reset), .dataOut(Out_Wire));
memoryInst memI(.addrs(Out_Wire), .instruction(inst_Wire)); 

assign PC = Out_Wire;
assign instructionF = inst_Wire;

endmodule


module Fetch_TB();

    reg clk_tb;
    reg reset_tb;
    reg [31:0] jump_address_tb;
    reg jump_tb;
    wire [31:0] instruction_tb;
    wire [31:0] PC_tb, next_PC_tb, PC_plus_4_tb;

    Fetch CF(
        .clkF(clk_tb),
        .reset(reset_tb),
        .jump_address(jump_address_tb),
        .jump(jump_tb),
        .instructionF(instruction_tb),
        .PC(PC_tb),
        .next_PC(next_PC_tb),
        .PC_plus_4(PC_plus_4_tb)
    );

    initial begin
        clk_tb = 0;
        reset_tb = 1;
        jump_tb = 0;
        jump_address_tb = 32'd0;

        #5 reset_tb = 0;

        // Simula algunos ciclos de reloj
        repeat (10) begin
            #5 clk_tb = ~clk_tb;
            #5 clk_tb = ~clk_tb;
        end
    end

endmodule



