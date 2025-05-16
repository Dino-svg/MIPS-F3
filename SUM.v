module SUM( 
    input [31:0] addrs,
    output [31:0] addrsOut
);

assign addrsOut = addrs + 32'd4;

endmodule
