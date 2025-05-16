module multiplexor(
    input wire[31:0]A_mux,
    input wire[31:0]B_mux,
    input wire mux_sel,
    output reg[31:0]salida_mux
);

always@(*) 
	begin
		if(mux_sel)
		begin
			salida_mux = A_mux;  
		end
		
		else
		begin
			salida_mux = B_mux; 
		end
	end
endmodule
