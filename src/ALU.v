`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 04.03.2018 
// Last Modification Date: 19.03.2018
// Design Name: Processor
// Module Name: ALU
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: Module for performing arithmetic operations based on the instructions (opcode) from ROM
//                     Called in the processor module
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task).
*/


    module ALU(
                //standard signals
                input CLK,
                input RESET,
                //I/O
                input [7:0] IN_A,
                input [7:0] IN_B,
                input [3:0] ALU_Op_Code,
                output [7:0] OUT_RESULT
                );
                
    reg [7:0] Out;
    
    //Arithmetic Computation
    always@(posedge CLK) 
    begin
        if(RESET)
            Out <= 0;
    else 
        begin
        
            case (ALU_Op_Code)
                //Maths Operations
                //Add A + B
                4'h0: Out <= IN_A + IN_B;
                
                //Subtract A - B
                4'h1: Out <= IN_A - IN_B;
        
                //Multiply A * B
                4'h2: Out <= IN_A * IN_B;
        
                //Shift Left A << 1
                4'h3: Out <= IN_A << 1;
                
                //Shift Right A >> 1
                4'h4: Out <= IN_A >> 1;
                
                //Increment A+1
                4'h5: Out <= IN_A + 1'b1;
                
                //Increment B+1
                4'h6: Out <= IN_B + 1'b1;
                
                //Decrement A-1
                4'h7: Out <= IN_A - 1'b1;
                
                //Decrement B+1
                4'h8: Out <= IN_B - 1'b1; 
                
                // In/Equality Operations
                //A == B
                4'h9: Out <= (IN_A == IN_B) ? 8'h01 : 8'h00;
                
                //A > B
                4'hA: Out <= (IN_A > IN_B) ? 8'h01 : 8'h00;
                
                //A < B
                4'hB: Out <= (IN_A < IN_B) ? 8'h01 : 8'h00;
                
                //A[0] ~^ B[0]
                4'hC: Out <= {7'b0000000, (IN_A[0] ~^ IN_B[1])}; 
                
                //Default A
                default: Out <= IN_A;
                
                endcase
            end
        end
            
        assign OUT_RESULT = Out;
        
    endmodule
