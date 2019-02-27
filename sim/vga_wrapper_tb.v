`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2018 11:28:04
// Design Name: 
// Module Name: vga_wrapper_tb
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


module vga_wrapper_tb(

    );
    
reg CLK;
reg RESET;
//reg [15:0] CONFIG_COLOURS;

wire [7:0] VGA_COLOUR;
wire VGA_HS;
wire VGA_VS;    
    
vga_wrapper uut(
            .CLK(CLK),
            .RESET(RESET),
//            .CONFIG_COLOURS(CONFIG_COLOURS),
            .VGA_COLOUR(VGA_COLOUR),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS)
            );



    initial
        CLK = 0;
        
    always
        #10 CLK <= ~CLK;
    
    initial
    begin
//        CONFIG_COLOURS = 16'hAA00;
        RESET = 1'b0;
        #10 RESET = 1'b1;
        #20 RESET = 1'b0;
    end

endmodule
