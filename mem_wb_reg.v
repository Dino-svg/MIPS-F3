module MEM_WB_Reg(
    input clk,
    input [31:0] MemReadData_in, ALU_result_in,
    input [4:0] rd_in,
    input [1:0] control_in, 
    output reg [31:0] MemReadData_out, ALU_result_out,
    output reg [4:0] rd_out,
    output reg [1:0] control_out
);
    always @(posedge clk) begin
        MemReadData_out <= MemReadData_in;
        ALU_result_out <= ALU_result_in;
        rd_out <= rd_in;
        control_out <= control_in;
    end
endmodule
