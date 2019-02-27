`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2018 10:21:49
// Design Name: 
// Module Name: vga_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module VGA_Sig_Gen(
		input CLK,
		input RESET,
//		input A_RE,
		//Colour Configuration Interface
		input [15:0] CONFIG_COLOURS,
		// Frame Buffer (Dual Port memory) Interface
		output DPR_CLK,
		output [16:0] VGA_ADDR,
		input VGA_DATA,
		//VGA Port Interface
		output reg VGA_HS,
		output reg VGA_VS,
		output reg [7:0] VGA_COLOUR
		);
	
	// check if the actual clock is 100 MHz
	//Halve the clock to 25MHz to drive the VGA display
	//wire VGA_CLK;

    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                       )
                       FreqCounter (
                       .CLK(CLK),
                       .ENABLE_IN(1'b1),
                       .RESET(1'b0),
                       .TRIG_OUT(VGA_CLK)
                       );
	
	
/*
Define VGA signal parameters e.g. Horizontal and Vertical display time, pulse widths, front and back
porch widths etc.
*/
	// Use the following signal parameters
	parameter HTs = 800; // Total Horizontal Sync Pulse Time
	parameter HTpw = 96; // Horizontal Pulse Width Time
	parameter HTDisp = 640; // Horizontal Display Time
	parameter Hbp = 48; // Horizontal Back Porch Time
	parameter Hfp = 16; // Horizontal Front Porch Time
	// Added horizontal parameter
	parameter HorTimeToBackPorchEnd = HTpw + Hbp; // 144
	parameter HorTimeToDispEnd = HTs - Hfp;  //784
	
	parameter VTs = 521; // Total Vertical Sync Pulse Time
	parameter VTpw = 2; // Vertical Pulse Width Time
	parameter VTDisp = 480; // Vertical Display Time
	parameter Vbp = 29; // Vertical Back Porch Time
	parameter Vfp = 10; // Vertical Front Porch Time
	// Added vertical parameters
	parameter VertTimeToBackPorchEnd = VTpw + Vbp; //  31
	parameter VertTimeToDispEnd = 511;//VTs - Vfp; // 511
	
 // Define Horizontal and Vertical Counters to generate the VGA signals
	wire [9:0] HCounter; 
	wire [8:0] VCounter; // 9 --> 8
	
	wire HorTriggOut;
	
	reg [9:0] H_ADDR;
	reg [8:0] V_ADDR;
/*
Create a process that assigns the proper horizontal and vertical counter values for raster scan of the
display.
*/

	// This is a counter to count the horizontal pixel position
    // Need to Generic_counter to the project
    Generic_counter # (.COUNTER_WIDTH(10),
                       .COUNTER_MAX(799)
                       )
                       HorizCounter (
                       .CLK(CLK),
                       .ENABLE_IN(VGA_CLK), // check the module to understand enable
                       .RESET(1'b0),
                       .TRIG_OUT(HorTriggOut),
                       .COUNT(HCounter)
                       );
                       
     // This is a counter to count the vertical pixel position                  
                       
     Generic_counter # (.COUNTER_WIDTH(9),
                        .COUNTER_MAX(520)
                       )
                       VerticalCounter (
                       .CLK(CLK),
                       .ENABLE_IN(HorTriggOut),
                       .RESET(1'b0),
//                       .TRIG_OUT(VerticalTriggOut),
                       .COUNT(VCounter)
                       );

/*
Need to create the address of the next pixel. Concatenate and tie the look ahead address to the frame
buffer address.
*/
assign DPR_CLK = VGA_CLK;
assign VGA_ADDR = {V_ADDR[8:1], H_ADDR[9:1]};
/*
Create a process that generates the horizontal and vertical synchronisation signals, as well as the pixel
colour information, using HCounter and VCounter. Do not forget to use CONFIG_COLOURS input to
display the right foreground and background colours.
*/

     always@( posedge CLK) begin
          if (HCounter < HTpw)
          VGA_HS <= 0;
          else 
          VGA_HS <= 1;
     end
     
     // Horizontal syncronization signal is generated if the horizontal count value is greater than 
     // Horizontal Time to pulse width end
     
     always@(posedge CLK) begin
          if (VCounter < VTpw)
          VGA_VS <= 0;
          else 
          VGA_VS <= 1;
     end
     
          // If the horizontal count is within the range, then its value is assigned to the horizontal address
     // subtracting the offset  value (144 pixels)
     // Otherwise, address is set to 0      
           
     always@(posedge CLK) begin
          if (HCounter < HorTimeToDispEnd && HCounter > HorTimeToBackPorchEnd)
                H_ADDR <= HCounter - HorTimeToBackPorchEnd;
          else 
                H_ADDR <= 0;      
     end           
     
     // If the vertical count is within the range, then its value is assigned to the vertical address
     // subtracting the offset  value (31 pixels)
     // Otherwise, address is set to 0 
     
     always@(posedge CLK) begin           
          if ( VCounter < VertTimeToDispEnd && VCounter > VertTimeToBackPorchEnd)
                 V_ADDR <= VCounter - VertTimeToBackPorchEnd;
          else 
                 V_ADDR <= 0;
     end
     // If the horizontal and vertical counts are within the dispaly range (we are reducing it from 800x521 to 640x480) then the 
     // the input colour is transmitted to screen; otherwise, colour is not transmitted and set to default -- black
     
    always@( posedge CLK) 
	begin
		if (HCounter < HorTimeToDispEnd && HCounter > HorTimeToBackPorchEnd 
            && VCounter < VertTimeToDispEnd && VCounter > VertTimeToBackPorchEnd)
        begin
			if(VGA_DATA)
				VGA_COLOUR <= CONFIG_COLOURS[15:8]; // foreground
			else if(~VGA_DATA)
				VGA_COLOUR <= CONFIG_COLOURS[7:0]; // background 
		end
		else
			VGA_COLOUR <= 8'h00;
    end      

/*
Finally, tie the output of the frame buffer to the colour output VGA_COLOUR.
*/

// see above

endmodule

