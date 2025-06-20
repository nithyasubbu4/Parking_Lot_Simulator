/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

// This module handles the flow of car data within the system. It
// includes the logic for updating and maintaining the parking
// lot count, managing signals related to entry and exit, 
// and interacting with other components of the system. This module 
//also outputs the rushHourStart and end hours
module datapath (clk, reset, entrance_gate, exit_gate, hour, currCar, noRush, 
						noEnd, totalCars, rushHourStart, rushHourEnd);
	
	input logic clk, reset, entrance_gate, exit_gate;
	input logic [2:0] hour;
	
	output logic [1:0] currCar;
	output logic [3:0] totalCars;
	output logic [2:0] rushHourStart, rushHourEnd;
	output logic noRush, noEnd;
	
	logic rush;
	
	assign noRush = ~rush;
	
	//adds one to the currCar count if there is a car at the enterance and there
	//is a spot open and it decreases the currCar count if there is a car at exit
	//and their was atleast one car already parked
	always_ff @(posedge clk) begin
		if(reset) begin
			currCar <= 0;
			totalCars <= 0;
		end else begin
			if(entrance_gate & (currCar < 3)) begin
				currCar <= currCar + 1;
				totalCars <= totalCars + 1;
				
			end
			
			if(exit_gate & (currCar > 0)) begin
				currCar <= currCar - 1;
			end
		end
	end
	
	//Controls the rush hour data by reseting values to 0 except for noEnd = 1
	//is high and when there is no previous rush and the total number of cars
	//is 3 then rush hour has started and if the total count of cars is 0 but
	//previously the rush hasn't ended you can say it ended now and that hour
	//is the end hour of rush.
	always_ff @(posedge clk) begin
		if(reset) begin
			rushHourStart <= 0;
			rushHourEnd <= 0;
			rush <= 0;
			noEnd <= 1;
		end 
		
		else begin			
			if((rush == 0) && (currCar == 3)) begin
				rush <= 1;
				rushHourStart <= hour;
			end 
			
			if((rush == 1) && (noEnd == 1) && (currCar == 0)) begin
				noEnd <= 0;
				rushHourEnd <= hour;
			end		
		end
	end
endmodule //datapath

//testbench for datapath tests all expected, unexpected and edgecase behaviors
module datapath_testbench();
	logic clk, reset, entrance_gate, exit_gate;
	logic [2:0] hour;
	
	logic [1:0] currCar;
	logic [3:0] totalCars;
	logic [2:0] rushHourStart, rushHourEnd;
	logic noRush, noEnd;
	
	logic rush;
	
	datapath dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
			
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; 																		@(posedge clk);
		reset <= 0; entrance_gate <= 0; exit_gate <= 0; hour <= 0; 			@(posedge clk);
		hour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); // Hour 1, count = 1
		hour <= 0; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
		hour <= 0; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   
		hour <= 1; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 2 count = 1
	   hour <= 1; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0
	   hour <= 1; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 1
	   hour <= 1; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		hour <= 2; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 3 count = 2
	   hour <= 2; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3 //RUSH START
	   hour <= 2; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3
	   hour <= 2; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 2
	   
		hour <= 3; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 4 count = 2  
	   hour <= 3; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   hour <= 3; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		hour <= 4; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 5 count = 2
	   hour <= 4; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 3
	   hour <= 4; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 2
	   
		hour <= 5; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 6 count = 2
	   hour <= 5; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   hour <= 5; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0 //RUSH ENDS
	   hour <= 5; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); //count = 0
	   
		hour <= 6; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 7 count = 0
	   hour <= 6; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 0
	   hour <= 6; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 1
	   hour <= 6; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   
		hour <= 7; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk); // Hour 8 count = 2
	   hour <= 7; entrance_gate <= 0; exit_gate <= 1;  @(posedge clk); //count = 1
	   hour <= 7; entrance_gate <= 1; exit_gate <= 0;  @(posedge clk); //count = 2
	   hour <= 7; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk);
	   hour <= 7; entrance_gate <= 0; exit_gate <= 0;  @(posedge clk);
	   
		reset <= 1; hour <= 0;             			@(posedge clk); 
	   reset <= 0;                               @(posedge clk); 
		                                          @(posedge clk); 
	
	   $stop;
	end
endmodule
	
	