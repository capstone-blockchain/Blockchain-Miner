`default_nettype none
`timescale 1 ns / 10 ps

module sha_256_tb;
	logic[31:0] message;
	logic [255:0] hashed;
	logic clk, rst, done, enable;
	integer in, out, statusI, statusO;

	function automatic [31:0] padded_size;
		input [31:0] message_size;
		padded_size = (message_size+1 > 448) ? ((message_size < 512) ? 1024 : padded_size(message_size-512)+512) : 512;
	endfunction

	sha_256 #(.MSG_SIZE(32), .PADDED_SIZE(padded_size(32))) uut (.message(message), .hashed(hashed), .clk(clk), .rst(rst), .enable (enable), .done(done));

	// generate clock
	always begin
	assign clk = 1; #5; assign clk = 0; #5; end
	
	initial begin
	
	message = "abcd";
    	assign rst = 1; #5
    	assign rst = 0; #50
	assign enable = 1;

	in = $fopen("input.txt", "r");
	out = $fopen("output.txt", "w");
	end
	 
	initial begin
	
	while (!$feof(in)) begin
    		@ (posedge done);
    		statusI = $fscanf(in,"%h\n",message);
    	end
	
	@ (posedge done);
	$fclose (in);
	$fclose (out);
	$finish;
	end

	always @ (posedge done)
	$fwrite(out, "%h\n", hashed);
endmodule