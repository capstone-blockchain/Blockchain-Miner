module hashing
  (input logic i_Clk, i_rst,
   input logic i_UART_RX,   // UART RX Data
   output logic o_UART_TX,   // UART TX Data
	output logic [6:0] hex0, hex1//, hex2, hex3, hex4, hex5
   );
  
 localparam MSG_SIZE = 8;
 localparam PADDED_SIZE = 512;
   
 logic rx_done;
 logic [7:0] rx_data;
 logic w_TX_Active, w_TX_Serial;
 
 logic[PADDED_SIZE-1:0] padded;
 logic hash_done;
 logic [255:0] hashed;
 
 sevenseg hex_0 (.in (rx_data[3:0]), .out (hex0));
 sevenseg hex_1 (.in (rx_data[7:4]), .out (hex1));
 
 // 50,000,000 / 115,200 = 434
 uart_rx #(.CLKS_PER_BIT(5208)) UART_RX_Inst
  (i_Clk,
   i_UART_RX,
   rx_done,
   rx_data);
   
 uart_tx #(.CLKS_PER_BIT(5208)) UART_TX_Inst
  (i_Clk,
   hash_done,
   hashed,
   w_TX_Active,
   w_TX_Serial);

 // Drive UART line high when transmitter is not active
 assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1;
 
 hashing_nonce 
 test (.data(rx_data), .hashed(hashed), .clk(i_Clk), .rst(i_rst), .enable(rx_done), .done(hash_done));
 
endmodule
