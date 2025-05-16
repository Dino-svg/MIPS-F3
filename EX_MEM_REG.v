module EX_MEM_Reg(
    input clk,
    input [31:0] ALU_result_in, RD2_in,
    input [4:0] rd_in,
    input [3:0] control_in, 
    output reg [31:0] ALU_result_out, RD2_out,
    output reg [4:0] rd_out,
    output reg [3:0] control_out
);
    always @(posedge clk) begin
        ALU_result_out <= ALU_result_in;
        RD2_out <= RD2_in;
        rd_out <= rd_in;
        control_out <= control_in;
    end
endmodule

