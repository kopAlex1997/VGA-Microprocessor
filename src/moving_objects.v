`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2016 16:32:04
// Design Name: 
// Module Name: extra_features
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:this module includes extra features for the vga control. It consists of several counters originated from generic
// counter to controlthe clock speed for different applications.
// here I implemented some logic to display the first letter of my name and 4 squares in the edges of the screen.
// There also is a separate logic to move all the objects on the screen.
// This module is also responsible for the colour change.
// extra_features communicates with the VGA_control in the wrapper module ( see the diagram in the labbook  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module moving_objects(
    input CLK,
    input RESET,
    input DATA_IN,
    input mv_en_hor,
    output reg WE,
    output [16:0] ADDR,
    output reg DATA_OUT
    );
    
     parameter HOR_SHIFT        = 96;
     parameter VERT_SHIFT       = 56;
     parameter ADDR_WDTH        = 15;
     parameter H_ADDR_WDTH      = 9;
     parameter V_ADDR_WDTH      = 8;
     parameter H_RES            = 320;
     parameter V_RES            = 240;
     parameter INTERVAL         = 40;
     parameter STRIPE_LEN       = 20;
    
    
     wire TRIGH;
     wire TRIGV;
     wire TRIGC;
     wire [9:0] HorPositionCount;
     wire [9:0] VertPositionCount;
           
       //Creating a counter to reduce the clock frequency
       //It provides the trigger for the colour counter
       //and horizontal counter
       Generic_counter # (.COUNTER_WIDTH(30),
                          .COUNTER_MAX(1499999)
                          )
                          HorFreqCounter (
                          .CLK(CLK),
                          .ENABLE_IN(1'b1),
                          .RESET(1'b0),
                          .TRIG_OUT(TRIGH)
                           );
                           
       //Creating a counter to reduce the clock frequency
       //It provides the trigger for the vertical counter
       Generic_counter # (.COUNTER_WIDTH(30),
                          .COUNTER_MAX(1499999)
                          )
                          VertFreqCounter (
                          .CLK(CLK),
                          .ENABLE_IN(1'b1),
                          .RESET(1'b0),
                          .TRIG_OUT(TRIGV)
                          );                                   
    
        //This counter is used to change the horizontal position of the elements non the screen                  
        Generic_counter # (.COUNTER_WIDTH(10),
                           .COUNTER_MAX(192)
                           )
                           PositionCounter (
                           .CLK(TRIGH),
                           .ENABLE_IN(mv_en_hor),
                           .RESET(RESET),
                           .COUNT(HorPositionCount)
                           );
                           
        //This counter is used to change the vertical position of the elements on the screen                   
        Generic_counter # (.COUNTER_WIDTH(10),
                           .COUNTER_MAX(20)
                           )
                           VerticalPositionCounter (
                           .CLK(TRIGV),
                           .ENABLE_IN(mv_en_hor),
                           .RESET(RESET),
                           .COUNT(VertPositionCount)
                           );
                           
       wire [H_ADDR_WDTH-1:0] H_ADDR;
       wire [V_ADDR_WDTH-1:0] V_ADDR;
       wire TRIG_1;
          
       // Counters to cycle through memory addresses for writing
       Generic_counter # (.COUNTER_WIDTH(H_ADDR_WDTH),
                          .COUNTER_MAX(319) 
                          )
                          h_frame_addr (
                          .CLK(CLK),
                          .ENABLE_IN(1'b1),
                          .RESET(1'b0),
                          .TRIG_OUT(TRIG_1),
                          .COUNT(H_ADDR)
                          );
                          
        // This is a counter to count the vertical pixel position                  
                          
        Generic_counter # (.COUNTER_WIDTH(V_ADDR_WDTH),
                           .COUNTER_MAX(239)
                          )
                          v_frame_addr (
                          .CLK(CLK),
                          .ENABLE_IN(TRIG_1),
                          .RESET(1'b0),
                          .TRIG_OUT(),
                          .COUNT(V_ADDR)
                          );
       
       assign ADDR = {V_ADDR[V_ADDR_WDTH-1:0], H_ADDR[H_ADDR_WDTH-1:0]};
       
       always @(posedge CLK or posedge RESET)
       begin
           if (RESET)
           begin
               if((ADDR[16:9] >= 64 && ADDR[16:9] <= 176) && (ADDR[8:0] >= 64 && ADDR[8:0] <= 256)) 
                   begin
                       WE <= 1'b1;
                       DATA_OUT <= 1'b1;
                   end
               else
               begin
                        WE <= 1'b0;
                        DATA_OUT <= 1'b1;
               end
           end
           else
           begin
//           // Restricted area that contains default picture (squares pattern)
           if((ADDR[16:9] > 190) && (ADDR[8:0] < 64 || ADDR[8:0] > 256)) 
           begin
               WE <= 1'b1;
               DATA_OUT <= 1'b1;
           end
//           // Write position of the moving object to memory
//           else if(ADDR[16:9] ==  (1 + VertPositionCount) && ADDR[8:0] == 160)
//           begin
//               WE <= 1'b1;
//               DATA_OUT <= 1'b0;
//           end
           
//           // Reset value in memory for the previous position of the object
//           else if (ADDR[16:9] ==  (1 + VertPositionCount - 1) && ADDR[8:0] == 160)
//           begin
//               WE <= 1'b1;
//               DATA_OUT <= 1'b1;
//           end
           
           
           else if (((ADDR[8:0] >= 100 && ADDR[8:0] <= 105) || (ADDR[8:0] <= 220 && ADDR[8:0] >= 215) ) && ((ADDR[16:9] >= (0 + VertPositionCount) && ADDR[16:9] <= (20 + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + INTERVAL + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + 2*INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + 2*INTERVAL + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + 3*INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + 3*INTERVAL + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + 4*INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + 4*INTERVAL + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + 5*INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + 5*INTERVAL + VertPositionCount)) ||
                    (ADDR[16:9] >= (0 + 6*INTERVAL + VertPositionCount) && ADDR[16:9] <= (20 + 6*INTERVAL + VertPositionCount)) ))
           begin
               WE <= 1'b1;
               DATA_OUT <= 1'b0;
           end
           
           else if (((ADDR[8:0] >= 100 && ADDR[8:0] <= 105) || (ADDR[8:0] <= 220 && ADDR[8:0] >= 215) ) && ((ADDR[16:9] >= (0 + VertPositionCount - 20) && ADDR[16:9] <= (20 + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + INTERVAL + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + 2*INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + 2*INTERVAL + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + 3*INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + 3*INTERVAL + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + 4*INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + 4*INTERVAL + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + 5*INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + 5*INTERVAL + VertPositionCount - 20)) ||
                    (ADDR[16:9] >= (0 + 6*INTERVAL + VertPositionCount - 20) && ADDR[16:9] <= (20 + 6*INTERVAL + VertPositionCount - 20)) ))
           begin
               WE <= 1'b1;
               DATA_OUT <= 1'b1;
           end
           
           // Nothing to write to memory
           else
           begin
               WE <= 1'b0;
               DATA_OUT <= 1'b1;
           end
           end
       end    

    
endmodule
