/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */
// This module manages vehicle entry and exit using sensors. It 
// keeps track of the number of cars in the lot, ensures the count 
// does not exceed capacity, and controls entry/exit signals.  
// The counter increments when a car enters and decrements when a 
// car exits, ensuring real-time monitoring of availability.

`timescale 1ns / 1ps

module parkingLotControl (clk, reset, entrance_gate, exit_gate, incrHour, 
								  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, currCar, isFull);
	
	input logic clk, reset, entrance_gate, exit_gate, incrHour;
	
	output logic [1:0] currCar;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic isFull;
	
	logic [2:0] hour;
	logic [3:0] totalCars;
	logic [2:0] rushHourStart, rushHourEnd;
	logic noRush, noEnd;
	logic done;
	
	logic [6:0] displayCars, displayTime, displayCurr, displayAddr, disRushStart, disRushEnd;
	logic [3:0] storedCarValue;
	logic [2:0] out;
	
	logic [31:0] div_clk;
	
	clock_divider divclk (.clock(clk), .divided_clocks(div_clk));
	
	logic clkSelect;
	parameter whichClock = 25;
	
	assign clkSelect = clk;
	//assign clkSelect = div_clk[whichClock];
	
	assign isFull = (currCar == 3);
	
	hourFSM fsm(.clk(clkSelect), .reset, .entrance_gate, .exit_gate, .incrHour, .hour, .done);
	
	datapath carData(.clk(clkSelect), .reset, .entrance_gate, .exit_gate, .hour, .currCar, 
							.noRush, .noEnd, .totalCars, .rushHourStart, .rushHourEnd);
	
	counter count(.clk(clkSelect), .reset, .out);
	
	ram8x16 ram(.clock(clkSelect), .data(totalCars), .rdaddress(out), .wraddress(hour), .wren(1'b1), .q(storedCarValue));
	
	//Display assignements for different types of data
	hexDisplay dispTime (.address({1'b0, hour}), .hex(displayTime)); //shows current hour
	hexDisplay dispCars (.address({2'b0, currCar}), .hex(displayCurr)); //shows current car count
	hexDisplay dispRushStart (.address({1'b0, rushHourStart}), .hex(disRushStart)); //shows rush's start hour
	hexDisplay dispRushEnd (.address({1'b0, rushHourEnd}), .hex(disRushEnd)); //shows rush's end hour
	hexDisplay dispOut (.address({1'b0, out}), .hex(displayAddr)); //shows address when looping through
	hexDisplay dispStoredCars (.address(storedCarValue), .hex(displayCars)); //shows # of cars in RAM
	
	//combinatinoal logic that helps decide what should be displayed on each HEX
	always_comb begin
		if(!done) begin
			if(currCar == 3) begin
				HEX5 = displayTime;
				HEX4 = 7'b1111111;
				HEX3 = 7'b0001110; //F
				HEX2 = 7'b1000001; //U
				HEX1 = 7'b1000111; //L			
				HEX0 = 7'b1000111; //L
			end 
			
			else begin
				HEX5 = displayTime;
				HEX4 = 7'b1111111;
				HEX3 = 7'b1111111;
				HEX2 = 7'b1111111;
				HEX1 = 7'b1111111;
				HEX0 = displayCurr;
			end
		end
		
		else begin
			HEX5 = 7'b1111111;
			HEX4 = (noRush) ? 7'b0111111 : disRushStart;
			HEX3 = (noEnd) ? 7'b0111111 : disRushEnd;
			HEX2 = displayAddr;
			HEX1 = displayCars;
			HEX0 = 7'b1111111;
		end
	end
endmodule


//parkingLotControl testbench that simulates all scenarios. 
module parkingLotControl_testbench();
	logic clk, reset, entrance_gate, exit_gate, incrHour;
	
	logic [1:0] currCar;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic isFull;

	logic [2:0] hour;
	logic [3:0] totalCars;
	logic [2:0] rushHourStart, rushHourEnd;
	logic noRush, noEnd;
	logic done;
	
	logic rush;
	
	logic [6:0] displayCars, displayTime, displayCurr, displayAddr, disRushStart, disRushEnd;
	logic [3:0] storedCarValue;
	logic [2:0] out;
	
	parkingLotControl dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; 									@(posedge clk);
															@(posedge clk);
		reset <= 0; entrance_gate <= 0; exit_gate <= 0;	@(posedge clk);
																		@(posedge clk);
		
		incrHour <= 1; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); // Hour 1, count = 1
		incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
		incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 2 count = 1
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 1
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 3 count = 2
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3 //RUSH START
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 2
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 4 count = 2  
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 5 count = 2
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 2
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 6 count = 2
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0 //RUSH ENDS
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); //count = 0
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 7 count = 0
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 1
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		incrHour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 8 count = 2
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   incrHour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk);
	   incrHour <= 0; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk);
	   
		reset <= 1; 			             			@(posedge clk); 
	   reset <= 0;                               @(posedge clk); 
		                                          @(posedge clk); 
	
	   $stop;
	end
endmodule
