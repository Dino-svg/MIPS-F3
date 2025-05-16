module IF_ID_Reg(
    input clk,
    input [31:0] inst_in, PC_plus_4_in,
    output reg [31:0] inst_out, PC_plus_4_out
);
    always @(posedge clk) begin
        inst_out <= inst_in;
        PC_plus_4_out <= PC_plus_4_in;
    end
endmodule