`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Edinburgh
// Engineer: Vladislav Rumiantsev
// 
// Create Date: 04.03.2018 
// Last Modification Date: 19.03.2018
// Design Name: Processor
// Module Name: timer
// Project Name: VGA Interface (Microprocessor Version) for DSL4
// Target Devices: Digilent BASYS3
// Tool Versions: Vivado 2015.2
// Module Description: Module for generating interrupts.
//
///////PROJECT DESCRIPTION///////
/*
    The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software
    has full control of VGA functionality 
    In this design, one "scene" can be displayed: - Chequered Image, 160*120 pixels resolution (basic task).
*/


    module timer(
    //standard signals
    input CLK,
    input RESET,
    //BUS signals
    inout [7:0] BUS_DATA,
    input [7:0] BUS_ADDR,
    input BUS_WE,
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK
     );
    parameter [7:0] TimerBaseAddr = 8'hF0; // Timer Base Address in the Memory Map
    parameter InitialIterruptRate = 100; // Default interrupt rate leading to 1 interrupt every 100 ms
    parameter InitialIterruptEnable = 1'b1; // By default the Interrupt is Enabled
    //////////////////////
    //BaseAddr + 0 -> reports current timer value
    //BaseAddr + 1 -> Address of a timer interrupt interval register, 100 ms by default 
    //BaseAddr + 2 -> Resets the timer, restart counting from zero
    //BaseAddr + 3 -> Address of an interrupt Enable register, allows the microprocessor to disable
     // the timer
    //This module will raise an interrupt flag when the designated time is up. It will
    //automatically set the time of the next interrupt to the time of the last interrupt plus
    //a configurable value (in milliseconds). 
    //Interrupt Rate Configuration - The Rate is initialised to 100 by the parameter above, but can 
    //also be set by the processor by writing to mem address BaseAddr + 1; 
    reg [7:0] InterruptRate;
    
    always@(posedge CLK) begin
        if(RESET)
            InterruptRate <= InitialIterruptRate;
        else if((BUS_ADDR == TimerBaseAddr + 8'h01) & BUS_WE)
            InterruptRate <= BUS_DATA;
    end
    //Interrupt Enable Configuration - If this is not set to 1, no interrupts will be
    //created.
    
    reg InterruptEnable;
    always@(posedge CLK) begin
        if(RESET)
            InterruptEnable <= InitialIterruptEnable;
        else if((BUS_ADDR == TimerBaseAddr + 8'h03) & BUS_WE) 
            InterruptEnable <= BUS_DATA[0];
    end
    //First we must lower the clock speed from 50MHz to 1 KHz (1ms period)
    
    reg [31:0] DownCounter;
    always@(posedge CLK) begin
        if(RESET)
            DownCounter <= 0;
        else 
        begin
            if(DownCounter == 32'd99999)
                DownCounter <= 0;
            else
                DownCounter <= DownCounter + 1'b1;
        end
    end
    //Now we can record the last time an interrupt was sent, and add a value to it to determine if it is
    // time to raise the interrupt.
    // But first, let us generate the 1ms counter (Timer)
    
    reg [31:0] Timer;
    
    always@(posedge CLK) begin
        if(RESET | (BUS_ADDR == TimerBaseAddr + 8'h02))
            Timer <= 0;
        else 
        begin
            if((DownCounter == 0))
                Timer <= Timer + 1'b1;
            else
                Timer <= Timer;
        end
    end
    //Interrupt generation
    
    reg TargetReached;
    reg [31:0] LastTime;
    
    always@(posedge CLK) begin
        if(RESET) 
        begin
            TargetReached <= 1'b0;
            LastTime <= 0;
        end 
        else if((LastTime + InterruptRate) == Timer) 
        begin
            if(InterruptEnable)
                TargetReached <= 1'b1;
            
            LastTime <= Timer;
        end 
        else
            TargetReached <= 1'b0;
        end
    //Broadcast the Interrupt
    reg Interrupt;
    
    always@(posedge CLK) begin
        if(RESET)
            Interrupt <= 1'b0;
        else if(TargetReached)
            Interrupt <= 1'b1;
        else if(BUS_INTERRUPT_ACK)
            Interrupt <= 1'b0;
    end
    
    assign BUS_INTERRUPT_RAISE = Interrupt;
    //Tristate output for interrupt timer output value
    
    reg TransmitTimerValue;
    
    always@(posedge CLK) begin
        if(BUS_ADDR == TimerBaseAddr)
            TransmitTimerValue <= 1'b1;
        else
            TransmitTimerValue <= 1'b0;
        end
    
    assign BUS_DATA = (TransmitTimerValue) ? Timer[7:0] : 8'hZZ;
    
    
    endmodule
    
    