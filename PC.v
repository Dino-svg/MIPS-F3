`timescale 1ns/1ns

module PC(
    input [31:0] dataIn,
    input clk,
    input reset,
    output reg [31:0] dataOut
);

initial begin 
    dataOut = 32'h00400000; 
end

always @(posedge clk or posedge reset) begin
    if (reset) dataOut <= 32'h00400000;
    else dataOut <= dataIn;  
end

endmodule
