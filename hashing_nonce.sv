module hashing_nonce (
	input logic 			clk, rst, enable,
	input logic [7:0] 	data,
	output logic 			done,
	output logic [31:0] 	golden_nonce,
	output logic [255:0] hashed);
	
	localparam PARALELL = 8;
   localparam RANGE = 2147483648/PARALELL;
	
	logic ctrl, check;
	
	logic [32*PARALELL-1 : 0] i_nonce;
	logic [256*PARALELL-1 : 0] i_hashed;
	logic [PARALELL-1 : 0] i_check;
	logic [7:0] old_data = 0;
	
	genvar i;
	generate 

		for (i = 0; i < PARALELL; i++) 
		begin: paralell_hashing
			
			nonce #(.START (i * RANGE)) try_nonce
			(.clk (clk), .rst (rst), .enable (ctrl), . check (i_check[i]), 
			.data (data), .hashed (i_hashed[256*i +: 256]), .golden_nonce (i_nonce[32*i +: 32]));

		end
		
	endgenerate
	
	always @(i_check) begin
		old_data = data;
		casez (i_check)
			8'b???????1: begin
				golden_nonce = i_nonce[32*0 +: 32];
				hashed = i_hashed [256*0 +: 256];
			end
			8'b??????1?: begin
				golden_nonce = i_nonce[32*1 +: 32];
				hashed = i_hashed [256*1 +: 256];
			end
			8'b?????1??: begin
				golden_nonce = i_nonce[32*2 +: 32];
				hashed = i_hashed [256*2 +: 256];
			end
			8'b????1???: begin
				golden_nonce = i_nonce[32*3 +: 32];
				hashed = i_hashed [256*3 +: 256];
			end
			8'b???1????: begin
				golden_nonce = i_nonce[32*4 +: 32];
				hashed = i_hashed [256*4 +: 256];
			end
			8'b??1?????: begin
				golden_nonce = i_nonce[32*5 +: 32];
				hashed = i_hashed [256*5 +: 256];
			end
			8'b?1??????: begin
				golden_nonce = i_nonce[32*6 +: 32];
				hashed = i_hashed [256*6 +: 256];
			end
			8'b1???????: begin
				golden_nonce = i_nonce[32*7 +: 32];
				hashed = i_hashed [256*7 +: 256];
			end
		endcase
	end
	
	assign check = |i_check;
	assign done = check;
	
	always_comb
	case (enable)
	1: begin
		if (((check === 1'bx) || (check == 1'b0)) || (data != old_data))
			begin			
			ctrl = 1'b1;
			end
		else  ctrl = 1'b0;
	end
	0: ctrl = 1'b0;
	endcase

endmodule
	