`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 23.01.2018 10:21:49
// Last Modification Date: 19.03.2018
// Design Name: VGA Interface
// Module Name: vga_wrapper
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: Version 1.0: This wrapper module connects all design files required for VGA interface to function.
//                     Version 1.1: Adjusted for integration with a microprocessor. Accepts data from common DATA_BUS and ADDRESS_BUS
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task).
*/
// Dependencies: Generic_Counter.v - parameterised counter developed in DSL3;
//               Frame_Buffer.v    - configurable memory buffer (template provided in terms of DSL4);
//               vga_control.v     - VGA signal generator (based on DSL4 and DSL3);
// 
//
//////////USER GUIDE//////////////
/*
    BUS Addresses:
                    - B0: Vertical Coordinate information (7 bits) + Pixel data information (1 bit) ({Y_ADDR,PIXEL_DATA})
                    - B1: Horizontal Coordinate infromation 
                    - B2: Colour change trigger
*/
//////////////////////////////////////////////////////////////////////////////////
//////////SIGNALS/////////////////
/*
    - CLK : system main clockV_SHIF
    - RESET : global reset
    - BUS_ADDR : System address bus
    - BUS_DATA : System data bus
    - VGA_COLOUR : colour output to be displayed
    - VGA_HS : VGA horizontal sync pulse
    - VGA_VS : VGA vertical sync pulse 
*/

    module vga_wrapper(
        input CLK,
        input RESET,
        input [7:0] BUS_ADDR,
        inout [7:0] BUS_DATA,
        output [7:0] VGA_COLOUR,
        output VGA_HS,
        output VGA_VS
        );
    // Outputs of the frame buffer 
    wire B_DATA_1;
    wire IMG_DATA;
    wire A_DATA_OUT;
    ////////////////////////////////////////////////////////    
    
    // Outputs of the vga control
    wire DPR_CLK;
    wire [14:0] VGA_ADDR;
    ///////////////////////////////////////////////////////
    
    // Read/Write memory control
    reg A_DATA_IN;
    wire [14:0] A_ADDR;
    reg A_WE;
    ///////////////////////////////////////////////////////
    
    // Colour selection controls
    wire TRIG_1_S;
    wire [7:0] ColourCount;
    reg COLOUR_IN;
    wire [15:0] CONFIG_COLOURS;
    
    reg [7:0] X_ADDR; 
    reg [6:0] Y_ADDR; 
    reg RE;
    
    // create colours for both fore- and background
    assign CONFIG_COLOURS = {ColourCount[7:0], 8'h15};
    
    // concatinate vertical and horizontal addresses
    assign A_ADDR = {Y_ADDR, X_ADDR};
        
    initial 
        RE <= 1'b1;
    
    // combinational logic to read from the data bus    
    always @(*)
    begin
        // get horizontal coordinate
        if (BUS_ADDR==8'hB1)
        begin
            X_ADDR <= BUS_DATA;
            A_WE <= 1'b0;
            COLOUR_IN <= 1'b0; 
        end
        
        // get vertical coordinate and pixel data
        else if (BUS_ADDR==8'hB0)
        begin
            Y_ADDR <= BUS_DATA[7:1];
            A_WE <= 1'b1;
            COLOUR_IN <= 1'b0;
            A_DATA_IN <= BUS_DATA[0];
        end
        // get colour change trigger
        else if (BUS_ADDR==8'hB2)
        begin
            COLOUR_IN <= BUS_DATA[0];
            A_WE <= 1'b0;
        end
        else
        begin
            X_ADDR <= X_ADDR;
            Y_ADDR <= Y_ADDR;
            A_WE <= 1'b0;
            COLOUR_IN <= 1'b0;
        end
    end
        
    // Determines the colour to be passed to VGA control
    // Triggered by the microprocessor
    Generic_counter # (.COUNTER_WIDTH(8),
                       .COUNTER_MAX(2**8-1)
                       )
                     COL_SELECT (
                     .CLK(COLOUR_IN),
                     .ENABLE_IN(1'b1),
                     .RESET(1'b0),
                     .COUNT(ColourCount[7:0])   
                     );
    
    
    // memory buffer to hold the basic chequered image, 160*120 pixels
    Frame_Buffer # (.HorRes(160),
                    .VertRes(120),
                    .HorConst(0),
                    .VertConst(8),
                    .image("Mymatrix_1d.txt")
                    )
    basic_image(
                    .A_CLK(CLK),           // standard clock (100MHz)
                    .A_ADDR(A_ADDR),       // address from the bus
                    .A_DATA_IN(A_DATA_IN), // data in from the bus
                    .A_DATA_OUT(), 
                    .A_WE(A_WE),        // enable signal set by combinational logic
                    .B_CLK(DPR_CLK),    // vga clock 
                    .B_ADDR(VGA_ADDR),  // vga address
                    .B_DATA(B_DATA_1)   // data out
                    );   
    
    // image data to VGA
    assign IMG_DATA = B_DATA_1; 

    // VGA control instantiation
    VGA_Sig_Gen vga_control(
                    .CLK(CLK),
                    .RESET(RESET),
                    .RE(RE), // read enable signal
                    //Colour Configuration Interface 
                    .CONFIG_COLOURS(CONFIG_COLOURS), 
                    // Frame Buffer (Dual Port memory) Interface
                    .DPR_CLK(DPR_CLK),
                    .VGA_ADDR(VGA_ADDR),
                    .VGA_DATA(IMG_DATA), // from frame buffer
                    //VGA Port Interface
                    .VGA_HS(VGA_HS),
                    .VGA_VS(VGA_VS),
                    .VGA_COLOUR(VGA_COLOUR)
                    ); 

endmodule


