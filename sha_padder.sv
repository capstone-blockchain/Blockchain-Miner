module sha_padder	#(parameter MSG_SIZE = 24,		// size of full message
			parameter PADDED_SIZE = 512) 
			(input logic [MSG_SIZE-1:0] message,
			output logic [PADDED_SIZE-1:0] padded);
	
	localparam zero_width = PADDED_SIZE-MSG_SIZE-1-64;
	localparam back_0_width = 64-$bits(MSG_SIZE);
	
	assign padded = {message, 1'b1, {zero_width{1'b0}}, {back_0_width{1'b0}}, MSG_SIZE};
endmodule