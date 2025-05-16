module ID_EX_Reg(
    input clk,
    input [31:0] RD1_in, RD2_in, SE_in, PC_in,
    input [4:0] rs_in, rt_in, rd_in,
    input [7:0] control_in, // señales de control desde Unidad de Control
    output reg [31:0] RD1_out, RD2_out, SE_out, PC_out,
    output reg [4:0] rs_out, rt_out, rd_out,
    output reg [7:0] control_out
);
    always @(posedge clk) begin
        PC_out <= PC_in;
        RD1_out <= RD1_in;
        RD2_out <= RD2_in;
        SE_out <= SE_in;
        rs_out <= rs_in;
        rt_out <= rt_in;
        rd_out <= rd_in;
        control_out <= control_in;
    end
endmodule
