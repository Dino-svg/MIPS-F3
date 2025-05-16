module ALU_control(
    input wire [5:0]op,
    input wire [2:0]Op_in,
    output reg [2:0]Op_out
);

always@(*) 
	begin
		case (Op_in)
			3'b010:									// Instrucciones tipo R
				case (op)
					6'b100000: Op_out = 3'b010;		//Suma
					6'b100010: Op_out = 3'b110;		//Resta
					6'b100100: Op_out = 3'b000;		//AND
					6'b100101: Op_out = 3'b001;		//OR
					6'b101010: Op_out = 3'b111;		//SLT
				endcase
			3'b001: Op_out = 3'd0;        			// Instrucciones tipo J
			3'b000: Op_out = 3'd0;       			// Instrucciones tipo I
			default: Op_out = 3'd0;       			// Por defecto, salida en 0
		endcase
	end
endmodule

