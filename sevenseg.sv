module sevenseg (input logic [3:0] in,
						output logic [6:0] out);
logic [6:0] n_out;
						
always_comb
case (in)

0: n_out = 7'b1111110;
1: n_out = 7'b0110000;
2: n_out = 7'b1101101;
3: n_out = 7'b1111001;
4: n_out = 7'b0110011;
5: n_out = 7'b1011011;
6: n_out = 7'b1011111;
7: n_out = 7'b1110000;
8: n_out = 7'b1111111;
9: n_out = 7'b1111011;
10: n_out = 7'b1110111;
11: n_out = 7'b0011111;
12: n_out = 7'b1001110;
13: n_out = 7'b0111101;
14: n_out = 7'b1001111;
15: n_out = 7'b1000111;

default: n_out = 7'b0000000;
endcase

assign out = ~n_out;

endmodule
