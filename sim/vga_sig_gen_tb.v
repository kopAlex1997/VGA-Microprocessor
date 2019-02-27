`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2018 09:17:28
// Design Name: 
// Module Name: vga_sig_gen_tb
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


module vga_sig_gen_tb(

    );

    reg CLK;
    reg [15:0] CONFIG_COLOURS;
    reg VGA_DATA;
    reg RESET;
    
    wire DPR_CLK;
    wire VGA_HS;
    wire VGA_VS;
    wire [14:0] VGA_ADDR;
    wire [7:0] VGA_COLOUR;

    
VGA_Sig_Gen uut(
            .CLK(CLK),
            .RESET(RESET),
            //Colour Configuration Interface
            .CONFIG_COLOURS(CONFIG_COLOURS),
            // Frame Buffer (Dual Port memory) Interface
            .DPR_CLK(DPR_CLK),
            .VGA_ADDR(VGA_ADDR),
            .VGA_DATA(VGA_DATA),
            //VGA Port Interface
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_COLOUR(VGA_COLOUR)
            ); 
    

    initial
        CLK = 0;
        
    always
        #10 CLK <= ~CLK;
    
    initial
    begin
        CONFIG_COLOURS = 16'hAA00;
        VGA_DATA = 0;
        RESET = 1'b0;
        #10 RESET = 1'b1;
        #20 RESET = 1'b0;
    end
    
    always
    begin
        #40 VGA_DATA <= ~VGA_DATA;
    end    
   
endmodule
