`timescale 1ns/1ns

module BR(
    input clk,                 
    input [4:0] adrsReadA,
    input [4:0] adrsReadB,
    input [4:0] adrsWrite,
    input RegEn,
    input [31:0] write,
    output reg [31:0] readA,
    output reg [31:0] readB,
    input jal  // Nueva señal para JAL
);

reg [31:0] BR_in [0:31];

integer i;

initial begin
    BR_in[0]  = 32'd0;    // $zero
    BR_in[5]  = 32'd20;   // $5 = 20
    BR_in[6]  = 32'd12;   // $6 = 12
    BR_in[7]  = 32'd55;   // $7 = 55
    BR_in[8]  = 32'd72;   // $8 = 72
    BR_in[9]  = 32'd100;  // $9 = 100
    BR_in[15] = 32'd999;  // $15 = 999
    BR_in[31] = 32'd0;    // $ra inicializado
    
    for (i = 1; i <= 4; i = i + 1) begin
        BR_in[i] = 32'd0;
    end
    for (i = 10; i <= 14; i = i + 1) begin
        BR_in[i] = 32'd0;
    end
    for (i = 16; i <= 30; i = i + 1) begin
        BR_in[i] = 32'd0;
    end
end

// Lectura asíncrona
always @(*) begin
    readA = BR_in[adrsReadA];
    readB = BR_in[adrsReadB];
end

// Escritura síncrona
always @(posedge clk) begin
    if (RegEn) begin
        if (jal)
            BR_in[31] <= write; 
        else
            BR_in[adrsWrite] <= write;
    end
end

endmodule