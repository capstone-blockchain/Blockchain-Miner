`default_nettype none
`timescale 1 ns / 10 ps

module nonce_tb;
	logic [7:0] data;
	logic [255:0] hashed;
	logic [31:0] golden_nonce;
	logic clk, rst, check, enable;
	
	nonce #(.START (10)) test
	(.clk (clk), .rst (rst), .enable (enable), . check (check) , .data (data), .hashed (hashed), .golden_nonce (golden_nonce));
	
	// generate clock
	always begin
	assign clk = 1; #5; assign clk = 0; #5; end
	
	initial begin
	
	assign rst = 1; #5
        assign rst = 0; #50
	assign enable = 1;
	assign data = 3;

	end
endmodule