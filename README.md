# VGA-Microprocessor
**Project Description**

The aim of the project is to implement full VGA control functionanlity on an FPGA. Microprocessor software has full control of VGA functionality. In this design, one "scene" can be displayed: - Chequered Image, 160x120 pixels resolution (basic task).

**Modules**

- processor_wrapper: top level module that connects processor and all peripherals together
- processor: implementation of the microprocessor
- RAM: memeory holding important parameters such as current vertical and horizontal VGA coordinates
- ROM: instruction memory
- ALU: arithmetic logic unit for the processor
- timer: timer to generate interrupts
- vga_wrapper: connects all design files required for VGA interface to function mand provides data & address bus interface
- vga_control: generates main VGA signals
- frame_buffer: dual port RAM to store image info to be displayed on the screen
- Generic_Counter: parameterised counter

**Architecture**

![alt text](https://raw.githubusercontent.com/vladrumyan/VGA-Microprocessor/additional_sources/to/uproc.png)

Credits: University of Edinburgh
