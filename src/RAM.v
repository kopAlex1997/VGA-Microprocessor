`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 04.03.2018 
// Last Modification Date: 19.03.2018
// Design Name: Processor
// Module Name: RAM
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: Temporary data storage memory
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software 
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task).
*/


    module RAM(
                //standard signals
                input CLK,
                //BUS signals
                inout [7:0] BUS_DATA,
                input [7:0] BUS_ADDR,
                input BUS_WE
                );
                
    parameter RAMBaseAddr  = 0;
    parameter RAMAddrWidth = 7; // 128 x 8-bits memory
    parameter RAMSize      = 128;
    
    //Tristate
    wire [7:0] BufferedBusData;
    reg [7:0] Out;
    reg RAMBusWE;
    
    //Only place data on the bus if the processor is NOT writing, and it is addressing this memory
    assign BUS_DATA = (RAMBusWE) ? Out : 8'hZZ;
    assign BufferedBusData = BUS_DATA;
    
    //Memory
    reg [7:0] Mem [2**RAMAddrWidth-1:0];
    
    // Initialise the memory for data preloading, initialising variables, and declaring constants 
        initial $readmemh("../additional_sources/full_ram.txt", Mem);
    
    //single port ram
    always@(posedge CLK) 
    begin
        if((BUS_ADDR >= RAMBaseAddr) & (BUS_ADDR < RAMBaseAddr + RAMSize))  
        begin
            if(BUS_WE) 
            begin
                Mem[BUS_ADDR[6:0]] <= BufferedBusData;
                RAMBusWE <= 1'b0;
            end 
            else
                RAMBusWE <= 1'b1;
        end 
        
        else
            RAMBusWE <= 1'b0;
            
        Out <= Mem[BUS_ADDR[6:0]];
    end
    
    endmodule
