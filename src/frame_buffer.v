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

module Frame_Buffer(
/// Port A - Read/Write
		input A_CLK,
		// comes from the wrapper
		input [16:0] A_ADDR, // 9 + 8 bits = 17 bits hence [16:0]
		input A_DATA_IN, // Pixel Data In
		////////////////////////////////////////////////////////
		output reg A_DATA_OUT,
		input A_WE, // Write Enable from the wrapper
		//Port B - Read Only
		input B_CLK,
		input [16:0] B_ADDR, // Pixel Data Out
		output reg B_DATA
		);
 
parameter HorRes    =   320;
parameter VertRes   =   240;
parameter HorConst  =   0;
parameter VertConst =   9;
parameter image     =   "/home/s1550706/Documents/dsl4/Mymatrix_1d_fr.txt";

 
 // A 256 x 128 1-bit memory to hold frame data
 //The LSBs of the address correspond to the X axis, and the MSBs to the Y axis
    //reg [0:0] Mem [19199:0];  // was 2**15-1
    reg [0:0] Mem [(HorRes*VertRes) - 1:0];
    
    initial
    begin
        $readmemb(image, Mem, 0, (HorRes*VertRes) - 1);
    end
    
//    always @ (posedge A_CLK)
//    begin
//        if (A_ADDR[7:0] < 32 || A_ADDR[7:0] > 128)
//        begin
//            for (i=0; i < 32; i = i +1)
//            begin
//                Mem[{A_ADDR[14:8] + 1'b1,A_ADDR[i]}] <= Mem[{A_ADDR[14:8],A_ADDR[i]}];
//            end
//        end 
//    end
    // Port A - Read/Write e.g. to be used by microprocessor
    always@(posedge A_CLK) 
    begin
        if(A_WE)
        begin
            //$readmemb("/home/s1550706/Documents/dsl4/Mymatrix_1d.txt", Mem, 0,'d19199);
            Mem[A_ADDR[16:VertConst]*HorRes + A_ADDR[8:HorConst]] <= A_DATA_IN;
        end
        
        A_DATA_OUT <= Mem[A_ADDR];
    end
    
    // Port B - Read Only e.g. to be read from the VGA signal generator module for display
    always@(posedge B_CLK)
    begin
 //       if(A_RE)
            B_DATA <= Mem[B_ADDR[16:VertConst]*HorRes + B_ADDR[8:HorConst]];
 //       else
 //           B_DATA <= 0;
    end
		
endmodule
