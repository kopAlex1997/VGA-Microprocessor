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


    module vga_wrapper(
        input CLK,
        input RESET,
        input mv_en_hor,
        input mv_en_vert,
        input [2:0] buf_sel,
        output [7:0] VGA_COLOUR,
        output VGA_HS,
        output  VGA_VS
        );
    // Outputs of the frame buffer 
    wire B_DATA;
    wire A_DATA_OUT;
    ////////////////////////////////////////////////////////    
    
    // Outputs of the vga control
    wire DPR_CLK;
    wire [16:0] VGA_ADDR;
    ///////////////////////////////////////////////////////
    
    // Read/Write memory control
//    reg A_WE;
    wire A_DATA_IN;
    wire [16:0] A_ADDR;
    wire A_WE;
    ///////////////////////////////////////////////////////
    
    wire TRIGC;
    wire [15:0] ColourCount;
    
      // This counter determines the frequency of the colours to change on the main screen during the idle state                   
      Generic_counter # (.COUNTER_WIDTH(23),
                         .COUNTER_MAX(2999999)
                         )
                         ColourFreqCounter (
                         .CLK(CLK),
                         .ENABLE_IN(1'b1),
                         .RESET(1'b0),
                         .TRIG_OUT(TRIGC)
                         );                   
      
      // This counter goes through all of the possible colours in the range, being triggerd by the ColourFreqCounter
      Generic_counter # (.COUNTER_WIDTH(8),
                         .COUNTER_MAX(2**8-1)
                         )
                         ColCounter (
                         .CLK(TRIGC),
                         .ENABLE_IN(1'b1),
                         .RESET(1'b0),
                         .COUNT(ColourCount[7:0])   // use only for either background/foreground
                         );
    
    
    
    Frame_Buffer # (.HorRes(160),
                    .VertRes(120),
                    .HorConst(1),
                    .VertConst(10),
                    .image("/home/s1550706/Documents/dsl4/Mymatrix_1d.txt")
                    )
    basic_image(
            .A_CLK(CLK),
            .A_ADDR(), // generated in the wrapper
            .A_DATA_IN(), // generated in the wrapper
            .A_DATA_OUT(), // not used
            .A_WE(), // enable signal set by the wrapper
            .B_CLK(DPR_CLK), // vga clock
            .B_ADDR(VGA_ADDR), // was vga address
            .B_DATA(B_DATA_1)
            );   
    
    
    Frame_Buffer # (.HorRes(320),
                    .VertRes(240),
                    .HorConst(0),
                    .VertConst(9),
                    .image("/home/s1550706/Documents/dsl4/racing_car.txt")
                    ) 
    car_image(
            .A_CLK(CLK),
            .A_ADDR(), // generated in the wrapper
            .A_DATA_IN(), // generated in the wrapper
            .A_DATA_OUT(), // not used
            .A_WE(), // enable signal set by the wrapper
            .B_CLK(DPR_CLK), // vga clock
            .B_ADDR(VGA_ADDR), // was vga address
            .B_DATA(B_DATA_2)
            );       

    Frame_Buffer # (.HorRes(320),
                    .VertRes(240),
                    .HorConst(0),
                    .VertConst(9),
                    .image("/home/s1550706/Documents/dsl4/back3.txt")
                    ) 
    game_image(
            .A_CLK(CLK),
            .A_ADDR(A_ADDR), // generated in the wrapper
            .A_DATA_IN(A_DATA_IN), // generated in the wrapper
            .A_DATA_OUT(A_DATA_OUT), // not used
            .A_WE(A_WE), // enable signal set by the wrapper
            .B_CLK(DPR_CLK), // vga clock
            .B_ADDR(VGA_ADDR), // was vga address
            .B_DATA(B_DATA_3)
            ); 
    
    // Select one of the memory buffers depending on external input
    assign IMG_DATA = (buf_sel==3'b000)?B_DATA_1:
                      (buf_sel==3'b010)?B_DATA_2:
                      (buf_sel==3'b011)?B_DATA_3:
                                        B_DATA_1;

    VGA_Sig_Gen vga_control(
            .CLK(CLK),
            .RESET(RESET),
            //Colour Configuration Interface
            .CONFIG_COLOURS({8'b00000000,ColourCount[7:0]}), // from wrapper
            // Frame Buffer (Dual Port memory) Interface
            .DPR_CLK(DPR_CLK),
            .VGA_ADDR(VGA_ADDR),
            .VGA_DATA(IMG_DATA), // from frame buffer
            //VGA Port Interface
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_COLOUR(VGA_COLOUR)
            ); 


        moving_objects move(
                    .CLK(CLK),
                    .RESET(RESET),
                    .DATA_IN(A_DATA_OUT),
                    .mv_en_hor(mv_en_hor),
                    .WE(A_WE),
                    .ADDR(A_ADDR),
                    .DATA_OUT(A_DATA_IN)
            );




endmodule


