module memoryInst(
    input [31:0] addrs,   
    output reg [31:0] instruction
);

reg [7:0] memory [0:1023]; 

integer i;
reg [31:0] addr_offset;

initial begin  
    $readmemb("datos.mem", memory);  
    $display("=== Contenido de Memoria ===");
    for (i = 0; i < 64; i = i + 4) begin
        $display("Mem[%2d-%2d] = %h%h%h%h", i, i+3, memory[i], memory[i+1], memory[i+2], memory[i+3]);
    end
end

always @(*) begin
    addr_offset = addrs - 32'h00400000;
    instruction = {
        memory[addr_offset],
        memory[addr_offset + 1],
        memory[addr_offset + 2],
        memory[addr_offset + 3]
    };
end

endmodule

