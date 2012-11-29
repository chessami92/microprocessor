`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:30:24 10/09/2012
// Design Name:   Microprocessor
// Module Name:   C:/Users/Joshua/Google Drive/CEEN 3100/microprocessor/microprocessor/src/test/MicroprocessorTest.v
// Project Name:  microprocessor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Microprocessor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MicroprocessorTest;

	// Inputs
	reg clk;

	// Outputs
	wire [31:0] programCounter;
	wire [31:0] aluResult;
	wire [31:0] r1;
	wire [31:0] r2;
	wire [31:0] r5;
	wire [31:0] r7;
	wire [31:0] mem25;

	// Instantiate the Unit Under Test (UUT)
	Microprocessor uut (
		.clk, 
		.programCounter,
		.aluResult,
		.r1,
		.r2,
		.r5,
		.r7,
		.mem25
	);

	initial begin
		clk = 1;
	end
	
	always begin
		#10 clk = ~clk;
	end
      
endmodule

