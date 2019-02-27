`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 12.03.2018 
// Last Modification Date: 19.03.2018
// Design Name: Processor Wrapper
// Module Name: processor_wrapper
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: This is the wrapper the microprocessor project. It connects the processor with the peripherals and memories.
//
/*
   Dependencies:
                Processor - main system processor
                timer     - interrupt timer
                RAM       - quick access memory for temporary dat storage
                ROM       - instruction memory
                VGA       - VGA interface
*/
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task).
*/


module processor_wrapper(
                    input CLK,
                    input RESET,
                    output [7:0] VGA_COLOUR,
                    output VGA_HS,
                    output VGA_VS
    );
    
    // bus declarations
    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    
    // ROM interconnects
    wire [7:0] ROM_DATA;
    wire [7:0] ROM_ADDRESS;
    
    // timer interconnects
    wire       BUS_INTERRUPT_RAISE_A;
    wire [1:0] BUS_INTERRUPTS_ACK;
    
    wire [7:0] VGA_COLOUR;
    
    Processor Processor(
                    //Standard Signals
                    .CLK(CLK),
                    .RESET(RESET),
                    //BUS Signals
                    .BUS_DATA(BUS_DATA), // inout
                    .BUS_ADDR(BUS_ADDR), // out
                    .BUS_WE(BUS_WE), // out
                    // ROM signals
                    .ROM_ADDRESS(ROM_ADDRESS), // out
                    .ROM_DATA(ROM_DATA), // in
                    // INTERRUPT signals
                    .BUS_INTERRUPTS_RAISE(BUS_INTERRUPT_RAISE_A), // in
                    .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)  // out
                    );

    
    timer       timer(
                    //standard signals
                    .CLK(CLK),
                    .RESET(RESET),
                    //BUS signals
                    .BUS_DATA(BUS_DATA), // inout
                    .BUS_ADDR(BUS_ADDR), // in
                    .BUS_WE(BUS_WE), // in
                    .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE_A), // out
                    .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[0]) // in
                     );
                     
    RAM         RAM0(
                     //standard signals
                    .CLK(CLK),
                    //BUS signals
                    .BUS_DATA(BUS_DATA),
                    .BUS_ADDR(BUS_ADDR), // in
                    .BUS_WE(BUS_WE)
                    );
                    
    ROM         ROM0(
                    //standard signals
                    .CLK(CLK),
                    //BUS signals
                    .DATA(ROM_DATA),
                    .ADDR(ROM_ADDRESS)
                    );
                    
    vga_wrapper VGA(
                    .CLK(CLK),
                    .RESET(RESET),
                    .BUS_ADDR(BUS_ADDR),
                    .BUS_DATA(BUS_DATA),
                    .VGA_COLOUR(VGA_COLOUR),
                    .VGA_HS(VGA_HS),
                    .VGA_VS(VGA_VS)
                    );


endmodule
