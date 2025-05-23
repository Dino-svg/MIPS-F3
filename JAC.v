`timescale 1ns/1ns

module JumpAddressCalculator(
    input [31:0] PC_plus_4,
    input [25:0] target_address,
    output [31:0] jump_address
);
    // Concatenar los 4 bits superiores 
    assign jump_address = {PC_plus_4[31:28], target_address, 2'b00};
endmodule
