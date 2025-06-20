/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

/*top level entity of the project */
//DE1_SoC uses a 12 bit V_GPIO as inputs and returns a 7bit HEX0, HEX1, HEX2, HEX3, HEX4
//HEX5 and 10-bit LEDR as outputs.This display is driven as "0" and nothing as the enter 
//or exit signal is high it increases or decreases respectivley and displayed on HEX0 
//and HEX1. When the capacity of the car park is reached(3) HEX0-HEX3 display 
//"FULL". This serves as the top-level module for the car sensor system 
//implemented in this lab. 
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, V_GPIO);

	// define ports
	input  logic CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [9:0] LEDR;
	inout  logic [35:23] V_GPIO;

	logic [1:0] currCar;
	logic reset;
	logic incrHour;
	logic enter, exit;
		
	//assign clk = CLOCK_50; //for simulation
	assign reset = SW[9];
	
	logic isFull;
	logic [31:0] div_clk;
	
	logic fullLight;

	// FPGA output
	assign V_GPIO[26] = V_GPIO[28];	// LED parking 1
	assign V_GPIO[27] = V_GPIO[29];	// LED parking 2
	assign V_GPIO[32] = V_GPIO[30];	// LED parking 3	
	assign V_GPIO[34] = isFull;		//LED full
	assign V_GPIO[31] = V_GPIO[23];	// Open entrance
	assign V_GPIO[33] = V_GPIO[24];	// Open exit

	// FPGA input
	assign LEDR[0] = V_GPIO[28];	// Presence parking 1
	assign LEDR[1] = V_GPIO[29];	// Presence parking 2
	assign LEDR[2] = V_GPIO[30];	// Presence parking 3
	assign LEDR[3] = V_GPIO[23];	// Presence entrance
	assign LEDR[4] = V_GPIO[24];	// Presence exit
	
	clock_divider clockDiv (.clock(CLOCK_50), .divided_clocks(div_clk));
	
	logic clk1, clk24;
	parameter whichClock = 26;
	
	assign clkSelect = CLOCK_50; //for simulation
	
	//assign clk1 = div_clk[1]; //for exiting
	//assign clk24 = div_clk[24]; //for entering
	
	always_ff @(posedge CLOCK_50) begin
		if (V_GPIO[23] && V_GPIO[31]) begin
			enter <= 1;
		end else
			enter <= 0;
	end
	
	always_ff @(posedge CLOCK_50) begin
		if (V_GPIO[24] | LEDR[4] | V_GPIO[33]) begin
			exit <= 1;
		end else
			exit <= 0;
	end
	
	parkingLotControl control (.clk(CLOCK_50), .reset, .entrance_gate(enter), .exit_gate(exit), .incrHour(~KEY[0]),
								  .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .currCar(currCar), .isFull(isFull));	
	
endmodule  // DE1_SoC

`timescale 1ns / 1ps
//DE1_SoC_testbench tests all expected, unexpected and edgecase behaviors
module DE1_SoC_testbench(); 

	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [9:0] LEDR;
	wire [35:23] V_GPIO;
	
	logic reset;
	logic [1:0] currCar;
	logic incrHour;
	logic isFull;
	logic enter, exit;

	
	assign KEY[0] = ~incrHour;
	assign SW[9] = reset;
	assign V_GPIO[23] = enter;	// Presence entrance && enter
	assign V_GPIO[24] = exit;	// Presence exit && exit
	
	DE1_SoC dut (.CLOCK_50(CLOCK_50), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .KEY(KEY), .SW(SW), 
					.LEDR(LEDR), .V_GPIO(V_GPIO));
	
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin 
		reset <= 1; 															@(posedge CLOCK_50);
																					@(posedge CLOCK_50);
		reset <= 0; enter <= 0; exit <= 0;								@(posedge CLOCK_50);
																					@(posedge CLOCK_50);
		
		incrHour <= 1; enter <= 1; exit <= 0;  @(posedge CLOCK_50); // Hour 1, count = 1
		incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 2
		incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 1
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 2 count = 1
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 0
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 1
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 2
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 3 count = 2
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 3 //RUSH START
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 3
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 2
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 4 count = 2  
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 1
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 2
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 5 count = 2
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 3
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 2
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 6 count = 2
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 1
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 0 //RUSH ENDS
	   incrHour <= 0; enter <= 0; exit <= 0;  @(posedge CLOCK_50); //count = 0
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 7 count = 0
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 0
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 1
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 2
	   
		incrHour <= 1; enter <= 0; exit <= 0;  @(posedge CLOCK_50); // Hour 8 count = 2
	   incrHour <= 0; enter <= 0; exit <= 1;  @(posedge CLOCK_50); //count = 1
	   incrHour <= 0; enter <= 1; exit <= 0;  @(posedge CLOCK_50); //count = 2
	   incrHour <= 0; enter <= 0; exit <= 0;  @(posedge CLOCK_50);
	   incrHour <= 0; enter <= 0; exit <= 0;  @(posedge CLOCK_50);
	   
		reset <= 1; 			             			@(posedge CLOCK_50); 
	   reset <= 0;                               @(posedge CLOCK_50); 
		                                          @(posedge CLOCK_50); 
		$stop();
	end
endmodule 