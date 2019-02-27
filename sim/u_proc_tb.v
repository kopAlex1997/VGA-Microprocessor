`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2018 17:45:48
// Design Name: 
// Module Name: u_proc_tb
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


module u_proc_tb(

    );
    
    reg CLK;
    reg RESET;
    wire VGA_VS;
    wire VGA_HS;
    wire [7:0] VGA_COLOUR;
    
    processor_wrapper ut(
                        .CLK(CLK),
                        .RESET(RESET),
                        .VGA_COLOUR(VGA_COLOUR),
                        .VGA_HS(VGA_HS),
                        .VGA_VS(VGA_VS)
        );
    
    
    initial
        CLK = 1'b0;
        
    always
        #5 CLK <= ~CLK;
        
        
    initial begin
        RESET = 1'b0;
        #10 RESET = 1'b1;
        #10 RESET = 1'b0;
    end
    
endmodule
