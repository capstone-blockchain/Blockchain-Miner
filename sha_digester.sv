module sha_digester 	#(parameter PADDED_SIZE = 512)
							(input logic clk,
                     input logic [PADDED_SIZE-1:0] padded,
							output logic [2047:0] w);
	
	function automatic [31:0] rho0;
		input [31:0] x;
		if(^x === 1'bX) rho0 = 32'h888;
		else rho0 = {x[6:0],x[31:7]} ^ {x[17:0],x[31:18]} ^ (x >> 3);
	endfunction

	function automatic [31:0] rho1;
		input [31:0] x;
		if(^x === 1'bX) rho1 = 32'h888;
		else rho1 = {x[16:0],x[31:17]} ^ {x[18:0],x[31:19]} ^ (x >> 10);
	endfunction
	
	genvar i;
	generate for (i=0; i<64; i++) begin : PreProcessing_Stage
	
	always_ff @(posedge clk) begin
	  if (i<16) begin
			w[2047-i*32 -: 32] <= padded[((PADDED_SIZE-1)-i*32) -: 32];
	  end
	  else begin
			w[2047-i*32 -: 32] <= rho1(w[2047-(i-2)*32 -: 32]) + w[2047-(i-7)*32 -: 32] + rho0(w[2047-(i-15)*32 -: 32]) + w[2047-(i-16)*32 -: 32];
	  end
	end
	end : PreProcessing_Stage
	endgenerate

endmodule
