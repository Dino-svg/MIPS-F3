module DataMem(
	input  wire[31:0]address,
	input  wire MemToWrite,
	input  wire[31:0] dataWrite,
	output reg [31:0] dataRead
);

reg [31:0]mem_out[0:31];

always@(*)
	begin
	//Escritura
	if(MemToWrite) 
	begin
		mem_out[address] = dataWrite;
	end
	
	//Lectura
	if(!(MemToWrite))
	begin
		dataRead = mem_out[address];
	end
end
endmodule
