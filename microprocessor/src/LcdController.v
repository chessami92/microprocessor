`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    	19:48:06 10/29/2012 
// Design Name: 
// Module Name:    	LcdController 
// Project Name: 		microprocessor
//
// Dependencies: 
//
//////////////////////////////////////////////////////////////////////////////////
module LcdController(
    input writeEnable,
    input [4:0] location,
    input [7:0] data,
	 input clk,
    output reg [11:8] SF_D, 
    output reg LCD_E,
    output reg LCD_RS,
    output reg LCD_RW
    );
	
	parameter CLEAR_DISPLAY = 8'b1;
	parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, SDone = 7;
	
	reg [7:0] characters[31:0];
	reg [31:0] updateFlag;
	reg [4:0] sendAddress;
	reg [7:0] sendData;
	
	reg pulseLcdE, pulseLcdEAck;
	reg [3:0] pulseLcdDelay;
	
	reg sendEnable, upperNibble, initialize, functionSet, entryModeSet, displayOn, clearDisplay;
	
	reg [19:0] delay; 
	reg [3:0] state;
	
	initial begin
		LCD_E = 0;
		
		LCD_RS = 0;
		LCD_RW = 0;
		
		updateFlag = 0;
		sendAddress = 0;
		sendData = 0;
		
		pulseLcdE = 0;
		pulseLcdEAck = 0;
		pulseLcdDelay = 0;
		
		sendEnable = 0;
		upperNibble = 1;
		initialize = 1;
		functionSet = 0;
		entryModeSet = 0;
		displayOn = 0;
		clearDisplay = 0;
		
		state = S0;
		//Wait to initialize display
		delay = 750000;
	end
	
	always @(posedge clk) begin
		characters[sendAddress] <= 7'h30 + sendAddress;
		
		if(pulseLcdE == 1) begin
			if(pulseLcdEAck == 0) begin
				LCD_E = 0;
				pulseLcdDelay = 12;
				pulseLcdEAck <= 1;
			end
			else begin
				if(pulseLcdDelay == 0) begin
					LCD_E = 0;
					pulseLcdE <= 0;
					pulseLcdEAck <= 0;
				end
				else begin
					LCD_E = 1;
					pulseLcdDelay = pulseLcdDelay - 1;
				end
			end
		end
		else if(delay == 0) begin
			if(sendEnable == 1) begin 
				if(upperNibble == 1) begin
					SF_D = sendData[7:4];
					LCD_RW = 0;
					
					pulseLcdE <= 1; 
					delay <= 50;
					
					upperNibble <= 0;
				end
				else begin
					SF_D = sendData[3:0];
					LCD_RW = 0;
					
					pulseLcdE <= 1;
					delay <= 2000;
					
					upperNibble <= 1;
					sendEnable <= 0;
				end
			end
			else if(initialize == 1) begin
				case(state)
					S0: begin
						SF_D = 4'h3;
						pulseLcdE <= 1;
						delay <= 2050000;
						state <= S1;
					end
					S1: begin
						SF_D = 4'h3;
						pulseLcdE <= 1;
						delay <= 5000;
						state <= S2;
					end
					S2: begin
						SF_D = 4'h3;
						pulseLcdE <= 1;
						delay <= 2000;
						state <= S3;
					end
					S3: begin
						SF_D = 4'h2;
						pulseLcdE <= 1;
						
						functionSet <= 1;
						entryModeSet <= 1;
						displayOn <= 1;
						clearDisplay <= 1;
						
						delay <= 2000;
						state <= SDone;
					end
					default: begin
						initialize <= 0;
						state <= S0;
					end
				endcase
			end
			else if(functionSet == 1) begin
				LCD_RS = 0;
				LCD_RW = 0;
				sendData <= 8'h28;
				sendEnable <= 1;
				
				functionSet <= 0;
			end
			else if(entryModeSet == 1) begin
				LCD_RS = 0;
				LCD_RW = 0;
				sendData <= 8'b0000_0110;
				sendEnable <= 1;
				
				entryModeSet <= 0;
			end
			else if(displayOn == 1) begin
				LCD_RS = 0;
				LCD_RW = 0;
				sendData <= 8'b0000_1100;
				sendEnable <= 1;
				
				displayOn <= 0;
			end
			else if(clearDisplay == 1) begin
				case(state)
					S0: begin
						LCD_RS = 0;
						LCD_RW = 0;
						sendData <= 8'h01;
						sendEnable <= 1;
						
						state <= S1;
					end
					S1: begin
						delay <= 82000;
						state <= SDone;
					end
					default: begin
						clearDisplay <= 0;
						state <= S0;
					end
				endcase
			end
			//Write characters to screen
			else begin
				case(state)
					S0: begin
						LCD_RS = 0;
						LCD_RW = 0;
						if(sendAddress == 0)
							sendData <= 8'b1000_0000;
						else if(sendAddress == 16)
							sendData <= 8'b1010_1000;
						
						sendEnable <= 1;
						
						state <= S1;
					end
					S1: begin
						LCD_RS = 1;
						LCD_RW = 0;
						sendData <= characters[sendAddress];
						
						if(updateFlag[sendAddress] == 0) begin
							sendEnable <= 1;
							//updateFlag[sendAddress] <= 1;
						end
						else begin
							sendEnable <= 0;
						end
						
						sendAddress <= sendAddress + 1;
						if(sendAddress == 15 | sendAddress == 31)
							state <= S0;
						
						//TEMPORARY FIX
						if(sendAddress == 31)
							updateFlag = 32'hFFFFFFFF;
					end
					default: state <= S0;
				endcase
			end
		end
		else begin
			delay <= delay - 1;
			if(sendEnable == 1 & upperNibble == 1) begin
				SF_D = sendData[7:4];
				LCD_RW = 0;
			end
			else
				LCD_RW = 1;
		end 
	end
endmodule