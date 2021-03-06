`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    	16:41:03 09/09/2012
// Design Name: 
// Module Name:    	Control
// Project Name: 		microprocessor
// Description: 		
//
// Dependencies: 		None
//
//////////////////////////////////////////////////////////////////////////////////
module Control(
    input [5:0] opCode,
	 input registerEqual,
    output wire [1:0] writeBackControl,
    output wire [1:0] memAccessControl,
    output wire [3:0] calculationControl,
	 output reg branch
    );

	reg regWrite, memToReg;
	reg memRead, memWrite;
	reg regDst, aluOp1, aluOp0, aluSrc;
	
	assign writeBackControl = {regWrite, memToReg};
	assign memAccessControl = {memRead, memWrite};
	assign calculationControl = {regDst, aluOp1, aluOp0, aluSrc};
	
	always @(opCode, registerEqual) begin
		case(opCode)
			'b000000 : begin //R format
				regWrite = 1; memToReg = 0;
				memRead = 0; memWrite = 0;
				regDst = 1; aluOp1 = 1; aluOp0 = 0; aluSrc = 0;
				branch = 0;
			end
			'b000001 : begin //Load Word
				regWrite = 1; memToReg = 1;
				memRead = 1; memWrite = 0;
				regDst = 0; aluOp1 = 0; aluOp0 = 0; aluSrc = 1;
				branch = 0;
			end
			'b000010 : begin //Store Word
				regWrite = 0; memToReg = 1'bx;
				memRead = 0; memWrite = 1;
				regDst = 1'bx; aluOp1 = 0; aluOp0 = 0; aluSrc = 1;
				branch = 0;
			end
			'b000011 : begin //Branch if Equal
				regWrite = 0; memToReg = 1'bx;
				memRead = 0; memWrite = 0; 
				regDst = 1'bx; aluOp1 = 1'bx; aluOp0 = 1'bx; aluSrc = 1'bx; 
				if(registerEqual == 1) branch = 1;
				else branch = 0;
			end	
			default : begin //Set to all unknowns
				regWrite = 1'bx; memToReg = 1'bx;
				memRead = 1'bx; memWrite = 1'bx; 
				regDst = 1'bx; aluOp1 = 1'bx; aluOp0 = 1'bx; aluSrc = 1'bx; 
				branch = 1'bx;
			end
		endcase
	end
endmodule
