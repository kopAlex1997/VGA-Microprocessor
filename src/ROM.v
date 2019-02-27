`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 04.03.2018 
// Last Modification Date: 19.03.2018
// Design Name: Processor
// Module Name: ROM
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: Instruction memory.
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task). 
*/


    module ROM( 
                //standard signals
                input CLK,
                //BUS signals
                output reg [7:0] DATA,
                input [7:0] ADDR
                );
                
    parameter RAMAddrWidth = 8;
    
    //Memory
    reg [7:0] ROM [2**RAMAddrWidth-1:0]; 
    
    // Load program
    initial 
        $readmemh("/home/s1550706/Documents/dsl4/line_pattern_gen5.txt", ROM);     
        
    //single port ram
    always@(posedge CLK) 
        DATA <= ROM[ADDR]; 
        
    endmodule
