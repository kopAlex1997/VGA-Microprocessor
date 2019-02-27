`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 23.01.2018 10:21:49
// Design Name: Frame buffer for image storage
// Module Name: Frame_Buffer.v
// Project Name: VGA Interface for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: This module implement parameterised dual port RAM. The memory size and address width can be 
//                     selected externally by changing corresponding parameters.
//                     Port A can be used for both Read and Write. Port B is Read only.
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. 
    In this design, three different "scenes" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task);
                                                               - Race Car image, 320*240 pixels (extra feature);
                                                               - Dynamic screen with a road and a moving car, 320*240 pixels (extra feature);
    All images change their color every second. Image can be selected with a combination of the switches on the board as described below.
*/
// Dependencies: none
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
    - A_CLK : clock for port A
    - A_ADDR : Port A memory cell address 
    - A_DATA_IN : Data to be stored at A_ADDR
    - A_DATA_OUT : memory contents output at A_ADDR
    - A_WE : enable memory change through Port A
    - B_CLK : Port B clock
    - B_ADDR : Port B memory cell address
    - B_DATA : memory contents output at A_ADDR
*/

module Frame_Buffer(
        // Port A - Read/Write
		input A_CLK,
		input [14:0] A_ADDR, // 9 + 8 bits = 17 bits hence [16:0]
		input A_DATA_IN, // Pixel Data In
		output reg A_DATA_OUT,
		input A_WE, 
		//Port B - Read Only
		input B_CLK,
		input [14:0] B_ADDR, 
		output reg B_DATA
		);
 
parameter HorRes    =   320;                    // Horizontal resolution in pixels
parameter VertRes   =   240;                    // Vertical resolution in pixels
parameter HorConst  =   0;                      // Horizontal address start (for resolution control from VGA)
parameter VertConst =   9;                      // Vertical address start (for resolution control from VGA)
parameter image     =   "Mymatrix_1d_fr.txt";   // File to fill the memory with data (should contain binary info)

 
    // A HorRes x VertRes 1-bit memory to hold frame data
    //The LSBs of the address correspond to the X axis, and the MSBs to the Y axis
    reg [0:0] Mem [(HorRes*VertRes) - 1:0];
    
    // initialise the memory from the file
//    initial
//    begin
//        $readmemb(image, Mem, 0, (HorRes*VertRes) - 1);
//    end
    
    // Port A - Read/Write e.g. to be used by microprocessor
    always@(posedge A_CLK) 
    begin
        if(A_WE)
        begin
            Mem[A_ADDR[14:8]*HorRes + A_ADDR[7:0]] <= A_DATA_IN;
        end
        
        A_DATA_OUT <= Mem[A_ADDR];
    end
    
    // Port B - Read Only e.g. to be read from the VGA signal generator module for display
    always@(posedge B_CLK)
    begin
            B_DATA <= Mem[B_ADDR[14:8]*HorRes + B_ADDR[7:0]];
    end
		
endmodule
