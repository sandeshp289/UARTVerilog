`timescale 1 ns / 100 ps

/////////////////////////////////////////////////////////////////////////////////////
// File       : uart.v
// Language   : Verilog
// Description: Universal Asynchronous Receiver-Transmitter (UART)
// Author     : Sandesh Prabhakar
// Created    : October 21, 2007
// Modified   : August 19, 2026
// Version    : 1.0
//
// Copyright (c) 2026 Sandesh Prabhakar
// All rights reserved
//////////////////////////////////////////////////////////////////////////////////////


//Transmitter
module transmit(TxD, busy, char, send, clock, reset);
output reg TxD;   // serial output
output busy;      // character transmission in progress
input [7:0] char; // ASCII character to send
input send;       // synchronous transmit enable
input clock;      // rising edge active
input reset;      // asynchronous active-high

reg [7:0]    t_reg;
reg          t_busy;
reg [3:0]    count;

assign busy = t_busy;

initial	begin    
   t_busy <= 0;
   TxD    <= 1;
end

always @ (posedge clock or posedge reset)

if (reset) begin
       t_reg        <= 0;
       t_busy       <= 0;
       
       //The line is held high when no data is transferred.
       TxD          <= 1;
       
       count        <= 0;
end 

else begin
      
        //The send control signal initiates character transmission.       
        if (send) begin
        t_reg   <= char;
        
        //busy is asserted to HIGH and it will remain HIGH till the character transmission is over.
        t_busy  <= 1;
        
        //start bit 0
        TxD <= 0;
        
        end

        //busy = HIGH implies character transmission in progress
        if (t_busy) begin
                count = count + 1;
                
                //the eight bits of the ASCII character starting with the most significant bit
                if (count > 0 && count < 9) begin
                TxD <= t_reg[8 - count];
                end
                
                //stop bit 1
                if (count == 9) begin
                    
                //The line is held high when transmission is complete / no data is transferred.
                TxD     <= 1;
                
                count   <= 0;
                t_busy  <= 0;
                end
        end
        
        else
        count <= 0;
        
end

endmodule


//Receiver
module receive(char, received, RxD, clock, reset);
output reg [7:0] char;  // ASCII character received
output received;        // indicates a character is available
input  RxD;             // serial input
input  clock;           // rising edge active
input  reset;           // asynchronous active-high

reg [7:0]    r_reg;
reg [3:0]    count;  
reg          r_frame_error;
reg          r_RxD;
reg          r_received;

assign received = r_received;

initial	begin    
   r_received <= 0;
end

always @ (posedge clock or posedge reset)

if (reset) begin
  r_reg          <= 0; 
  r_received     <= 0;
  count          <= 0;
  r_frame_error  <= 0;
  r_RxD          <= 1;
  char           <= 0;
  
end 

else begin
    
  assign r_RxD = RxD;
   
  if (r_received) begin
      r_received <= 0;
  end
  
    //if count = 0 and start bit 0 is received, increment count.
    if (!count && !r_RxD) begin
      count <= count + 1;
    end
    
    else begin
        
        if ((r_RxD == 1) && (count == 0)) begin
            r_reg <= 0;
        end 
        
        else begin
            count <= count + 1; 
            // Storing the received character data
            if (count > 0 && count < 9) begin
              r_reg[8 - count] <= r_RxD;
            end
            if (count == 9) begin
               //the received control signal indicates that data is available on the Rx char port 
               r_received <= 1;
               char  <= r_reg;
               
               // Frame error checking
               // Stop bit = 0 implies an error, r_frame_error is asserted
               if (r_RxD == 0) begin
                 r_frame_error <= 1;
                 count <= 0;
                 
               // Stop bit = 1 implies no error, r_frame_error remains at zero.  
               end else begin
                 count     <= 0;
                 r_frame_error <= 0;
               end
            end   
         end  
     end   
  end   
        
 endmodule
