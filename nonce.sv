module nonce #(parameter START = 0)
	(input logic clk, rst, enable,
	input logic [7:0] data,
	output logic [31:0] golden_nonce,
	output logic [255:0] hashed,
	output logic check);
	
 localparam MSG_SIZE = 40;
 localparam PADDED_SIZE = 512;
 
 logic hash_done;
 logic [255:0] target;
 logic [31:0] nonce = START;
 
 assign target = {256{1'b1}} >> data;
		
 sha_256 #(.MSG_SIZE(MSG_SIZE), .PADDED_SIZE(PADDED_SIZE)) 
			sha (.message({data, nonce}), .hashed(hashed), .clk(clk), .rst(rst), .enable(enable), .done(hash_done));
			
 always @(posedge hash_done) 
	begin
		if (hashed <= target) 
			begin
				golden_nonce <= nonce;
				check <= 1'b1;
			end
		else 
			begin
				nonce  <= nonce + 1;
				check <= 1'b0;
			end
	end
endmodule
 