//`default_nettype none
//`timescale 1 ns / 10 ps

module sha_mainloop	#(parameter PADDED_SIZE = 512)
					(input logic [PADDED_SIZE-1:0] padded,
					input logic clk, rst, enable,
					output logic [255:0] hashed,
					output logic done);
					
	logic [255:0] initial_hashes = {32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};
	
	logic [2047:0] k = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5, 32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174, 32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da, 32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967, 32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85, 32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070, 32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3, 32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};
	logic [2047:0] w;
	
	logic [31:0] a, b, c, d, e, f, g, h, t1, t2;
	
	logic [31:0] h1 = 32'h6a09e667;
	logic [31:0] h2 = 32'hbb67ae85;
	logic [31:0] h3 = 32'h3c6ef372;
	logic [31:0] h4 = 32'ha54ff53a;
	logic [31:0] h5 = 32'h510e527f;
	logic [31:0] h6 = 32'h9b05688c;
	logic [31:0] h7 = 32'h1f83d9ab;
	logic [31:0] h8 = 32'h5be0cd19;

	logic [6:0] j = 0;
	logic [1:0] SM, next_SM = 0;
	
	localparam INITIAL 	= 2'b00;
	localparam CALCULATE = 2'b01;
	localparam DONE		= 2'b10;
	localparam CLEAN	 	= 2'b11;
	
	sha_digester #(.PADDED_SIZE(PADDED_SIZE)) digester (.clk(clk), .padded(padded), .w(w));

	function [31:0] K;
		input [6:0] x;
		K = k[2047-x*32 -: 32];
	endfunction

	function [31:0] W;
		input [6:0] x;
		W = w[2047-x*32 -: 32];
	endfunction
	
	function [31:0] ch;
		input [31:0] x,y,z;
		if(^x === 1'bX) ch = 32'h888;
		else ch = (x & y) ^ (~x & z);
	endfunction

	function [31:0] maj;
		input [31:0] x,y,z;
		if(^x === 1'bX) maj = 32'h888;
		else maj = (x & y) ^ (x & z) ^ (y & z);
	endfunction

	function [31:0] sum0;
		input [31:0] x;
		if(^x === 1'bX) sum0 = 32'h888;
		else sum0 = {x[1:0],x[31:2]} ^ {x[12:0],x[31:13]} ^ {x[21:0],x[31:22]};
	endfunction

	function [31:0] sum1;
		input [31:0] x;
		if(^x === 1'bX) sum1 = 32'h888;
		else sum1 = {x[5:0],x[31:6]} ^ {x[10:0],x[31:11]} ^ {x[24:0],x[31:25]};
	endfunction

	localparam N = PADDED_SIZE/512; // number of blocks
	
	logic [31:0] ch_efg, maj_abc, sum0_a, sum1_e, kj, wj;
	
	always_comb begin
		ch_efg = ch(e,f,g);
		maj_abc = maj(a,b,c);
		sum0_a = sum0(a);
		sum1_e = sum1(e);
		wj = W(j);
		kj = K(j);
	end

	always @(negedge clk) begin
		// t1 <= h + sum1(e) + ch(e,f,g) + K(j) + W(j);
		// t2 <= sum0(a) + maj(a,b,c);
		t1 <= (h + sum1_e + ch_efg + kj + wj);
		t2 <= (sum0_a + maj_abc);
	end

	always @(posedge clk or posedge rst)
		if(rst) SM <= INITIAL;
		else SM <= next_SM;
	
	always @(posedge clk)
    begin
       
      case (SM)
		
			INITIAL:
			begin
			done <= 1'b0;
			j <= 1'd0;
			
			if (enable == 1'b1)
			begin
				a <= h1;
				b <= h2;
				c <= h3;
				d <= h4;
				e <= h5;
				f <= h6;
				g <= h7;
				h <= h8;
				next_SM <= CALCULATE;
			end
			else next_SM <= INITIAL;
			end
			
			CALCULATE:
			begin
			if (j <64)
			begin
			h <= g;
			g <= f;
			f <= e;
			e <= (d+t1);
			d <= c;
			c <= b;
			b <= a;
			a <= (t1+t2);
			
			j <= j+1;
			next_SM <= CALCULATE;
			end
			else if (j == 64) next_SM <= DONE;
			end
			
			DONE:
			begin
			hashed[255-:32] <= a + h1;
			hashed[223-:32] <= b + h2;
			hashed[191-:32] <= c + h3;
			hashed[159-:32] <= d + h4;
			hashed[127-:32] <= e + h5;
			hashed[95-:32] <= f + h6;
			hashed[63-:32] <= g + h7;
			hashed[31-:32] <= h + h8;
			
			done <= 1'b1;
			j <= 1'd0;
			next_SM <= CLEAN;
			end
			
			CLEAN: 
			begin
			done <= 1'b1;
			next_SM <= INITIAL;
			end
			
			default :
			next_SM <= INITIAL;
		endcase
	end
endmodule
