`timescale 1 ns / 100 ps

/////////////////////////////////////////////////////////////////////////////////////
// File       : uart_tb.v
// Language   : Verilog
// Description: Test bench for UART 
// Author     : Sandesh Prabhakar
// Created    : October 21, 2007
// Modified   : August 19, 2026
// Version    : 1.0
//
// Copyright (c) 2026 Sandesh Prabhakar
// All rights reserved
//////////////////////////////////////////////////////////////////////////////////////

module test_uart;

wire [7:0] char_received;
wire tx_busy;
wire received;
wire line;

reg  [7:0] char_sent; 
reg tx_clock;
reg rx_clock;
reg tx_reset;
reg rx_reset;
reg send;
  
transmit transmitter (line, tx_busy, char_sent, send, tx_clock, tx_reset);
receive receiver (char_received, received, line, rx_clock, rx_reset);


initial begin    // tx_clock generator
   tx_clock = 1;
   #10 tx_clock = 0;
   #10 tx_clock = 0;
   forever #10 tx_clock = !tx_clock;
end
  
initial begin    // rx_clock generator
   rx_clock = 1;
   #10 rx_clock = 0;
   #10 rx_clock = 0;
   forever #10 rx_clock = !rx_clock;
end
  
initial	begin    
   tx_reset = 0;
   #10 tx_reset = 1;   //tx_reset asserted
   #10 tx_reset = 0;   //tx_reset deasserted
end

initial	begin    
   rx_reset = 0;
   #10 rx_reset = 1;   //rx_reset asserted
   #10 rx_reset = 0;   //rx_reset deasserted
end

initial	begin          
    #20 send  = 1;      //send asserted to start transmitting character 'a'
    #20 send  = 0;      //send deasserted
    #400 send = 1;      //send asserted to start transmitting character 'z'
    #20 send  = 0;      //send deasserted
end

initial	begin              // test stimulus
        char_sent = 8'h61; //hexadecimal value corresponding to ASCII character 'a'
   #400 char_sent = 8'h7A; //hexadecimal value corresponding to ASCII character 'z'
end

endmodule 

