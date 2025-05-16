module ALU(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [2:0]  Sel,
    output reg [31:0] R
);

always@(*) 
	begin
		case (Sel)
			3'b000: R = A & B;        				// AND
			3'b001: R = A | B;        				// OR
			3'b010: R = A + B;       				// SUMA
			3'b110: R = A - B;        				// RESTA
			3'b111: R = (A < B) ? 32'd1 : 32'd0; 	// Ternario A < B	
			default: R = 32'd0;       				// Por defecto, resultado en 0
		endcase
	end
endmodule

