`default_nettype none
`timescale 1 ns / 10 ps

module hashing_nonce_tb;
	logic [7:0] data;
	logic [255:0] hashed;
	logic [31:0] golden_nonce;
	logic clk, rst, done, enable;
	integer in, out, statusI, statusO;
	
	hashing_nonce test
	(.clk (clk), .rst (rst), .enable (enable), . done (done) , .data (data), .hashed (hashed), .golden_nonce (golden_nonce));
	
	// generate clock
	always begin
	assign clk = 1; #5; assign clk = 0; #5; end
	
	initial begin
	
	assign rst = 1; #5
        assign rst = 0; #50
	assign enable = 1;
	data = 4;
	
	in = $fopen("input.txt", "r");
	out = $fopen("output.txt", "w");

	end
	
	initial begin
	
	while (!$feof(in)) begin
    		@ (posedge done);
    		statusI = $fscanf(in,"%h\n",data);
    	end
	
	@ (posedge done);
	$fclose (in);
	$fclose (out);
	$finish;
	end

	always @ (posedge done)
	$fwrite(out, "%h_%h\n", golden_nonce, hashed);
endmodule