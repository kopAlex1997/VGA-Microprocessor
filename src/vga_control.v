`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 23.01.2018 10:21:49
// Design Name: VGA Interface
// Module Name: vga_wrapper
// Project Name: VGA Interface for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: This module's primary purpose is to generate main VGA signals. It scans through each pixel and assigns it
//                     a colour based on the information received from the memory buffer.
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. 
    In this design, three different "scenes" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task);
                                                               - Race Car image, 320*240 pixels (extra feature);
                                                               - Dynamic screen with a road and a moving car, 320*240 pixels (extra feature);
    All images change their color every second. Image can be selected with a combination of the switches on the board as described below.
*/
// Dependencies: Generic_Counter.v - parameterised counter developed in DSL3;
// 
//
//////////USER GUIDE//////////////
/*
    - SW0 : Global RESET
    - SW2 : Display Race Car image
    - SW2 + SW1 : Display Moving Car
    - SW15 : Enable objects movement 
*/
//////////////////////////////////////////////////////////////////////////////////
//////////SIGNALS/////////////////
/*
    - CLK : system main clock
    - RESET : global reset
    - CONFIG_COLOURS : colour information foreground+background
    - DPR_CLK : VGA clock, 25MHz
    - VGA_DATA : pixel info for selected address
    - VGA_ADDR : pixel coordinates x+y
    - VGA_HS : VGA horizontal sync pulse
    - VGA_VS : VGA vertical sync pulse 
    - VGA_COLOUR : colour info sent to the screen
*/

    module VGA_Sig_Gen(
            input CLK,
            input RESET,
            input RE,
            //Colour Configuration Interface
            input [15:0] CONFIG_COLOURS,
            // Frame Buffer (Dual Port memory) Interface
            output DPR_CLK,
            output [14:0] VGA_ADDR,
            input VGA_DATA,
            //VGA Port Interface
            output reg VGA_HS,
            output reg VGA_VS,
            output reg [7:0] VGA_COLOUR
            );
	
	// Slow down the clock to 25MHz to drive the VGA display
    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                       )
                       MHz_25_CLK (
                       .CLK(CLK),
                       .ENABLE_IN(1'b1), // was  1
                       .RESET(1'b0),
                       .TRIG_OUT(VGA_CLK)
                       );

    reg VGA_CLK_2;
    reg [1:0] counter;
    
    always @ (posedge CLK)
    begin
        if (RESET)
            counter <= 2'b00;
        else //if (RE) // was without condition
            counter <= counter + 1'b1;
            
        if (counter == 2'b00 || counter == 2'b01) 
            VGA_CLK_2 <= 1'b0;
        else 
            VGA_CLK_2 <= 1'b1;
    end
    
//        always @ (posedge CLK)
//        begin
//            if (RESET)
//                counter <= 2'b00;
//            else //if (RE) // was without condition
//                counter <= counter + 1'b1;
//        end
        
//        always @ (*)   
//        begin     
//            if (counter == 2'b00 || counter == 2'b01) 
//                VGA_CLK_2 <= 1'b0;
//            else 
//                VGA_CLK_2 <= 1'b1;
//        end


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
	wire [8:0] VCounter; 
	
	// end of horizontal line trigger
	wire HorTriggOut;
	
	// horizontal/vertical addresses
	reg [9:0] H_ADDR;
	reg [8:0] V_ADDR;

    // Process that assigns the proper horizontal and vertical counter values for raster scan of the
    // display.

//    always @ (posedge VGA_CLK_2)
//    begin
//        if (RESET)
//        begin
//            HCounter <= 9'h00;
//            HorTriggOut <= 1'b0;
//        end
//        else if ( HCounter < HTs-1)
//        begin
//            HCounter <= HCounter + 1'b1;
//            HorTriggOut <= 1'b0;
//        end
//        else if (HCounter == HTs-1)
//        begin
//            HorTriggOut <= 1'b1;
//            HCounter <= 9'h00;
//        end
//    end
    
//	 This is a counter to scan through the horizontal pixel positions at 25MHz clock
    Generic_counter # (.COUNTER_WIDTH(10),
                       .COUNTER_MAX(HTs-1)
                       )
                       HorizCounter (
                       .CLK(VGA_CLK), // was VGA_CLK_2
                       .ENABLE_IN(1'b1), // was RE
                       .RESET(1'b0),
                       .TRIG_OUT(HorTriggOut),
                       .COUNT(HCounter)
                       );
                       
     // This is a counter to count the vertical pixel position                  
                       
     Generic_counter # (.COUNTER_WIDTH(9),
                        .COUNTER_MAX(VTs-1)
                       )
                       VerticalCounter (
                       .CLK(VGA_CLK_2),
                       .ENABLE_IN(HorTriggOut),
                       .RESET(1'b0),
                       .COUNT(VCounter)
                       );

     // Create pixel address from the counters' outputs
     assign DPR_CLK = VGA_CLK_2;
     assign VGA_ADDR = {V_ADDR[8:2], H_ADDR[9:2]};

     // Generate horizontal sync pulse - HS
     always@( posedge CLK) begin
          if (HCounter < HTpw)
          VGA_HS <= 0;
          else 
          VGA_HS <= 1;
     end
     
     // Generate vertical sync pulse - VS
     always@(posedge CLK) begin
          if (VCounter < VTpw)
          VGA_VS <= 0;
          else 
          VGA_VS <= 1;
     end
     
     // Detect out of range addresses based on VGA specs
     always@(posedge CLK) begin
          if (HCounter < HorTimeToDispEnd && HCounter > HorTimeToBackPorchEnd)
                H_ADDR <= HCounter - HorTimeToBackPorchEnd;
          else 
                H_ADDR <= 0;      
     end           
     
     // Detect out of range addresses based on VGA spec
     always@(posedge CLK) begin           
          if ( VCounter < VertTimeToDispEnd && VCounter > VertTimeToBackPorchEnd)
                 V_ADDR <= VCounter - VertTimeToBackPorchEnd;
          else 
                 V_ADDR <= 0;
     end
     
    // If address valid - assign colour based on data input from the buffer 
    always@( posedge CLK) 
	begin
		if (HCounter < HorTimeToDispEnd && HCounter > HorTimeToBackPorchEnd 
            && VCounter < VertTimeToDispEnd && VCounter > VertTimeToBackPorchEnd)
        begin
			if(~VGA_DATA)
		          VGA_COLOUR <= CONFIG_COLOURS[15:8]; // background
			else if(VGA_DATA)
				  VGA_COLOUR <= CONFIG_COLOURS[7:0]; // foreground 
		end
		else
			VGA_COLOUR <= 8'h00;
    end      

endmodule

