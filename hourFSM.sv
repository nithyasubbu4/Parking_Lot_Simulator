/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

// a state machine that increases the 3-bit hour signal when the input signal of
//incrHour is high and goes into the display state when we have completed
//a full day. It also outputs a one-bit signal that tells us when the day 
//is complete and takes in 1-bit clk, reset, incrHour and.
module hourFSM (clk, reset, entrance_gate, exit_gate, incrHour, hour, done);
	input logic clk, reset, incrHour;
	input logic entrance_gate, exit_gate;
	
	output logic [2:0] hour;
	output logic done;
	
	enum {idle, hour1, hour2, hour3, hour4, hour5, hour6, hour7, hour8, endStats} ps, ns;
	
	//the state logic for moving through each work hour
	//if incrHour is high it moves to next state else it stays in same state
	//the done signal is only high in the endStats state and hour increases
	always_comb begin
		case(ps)
			idle: begin
				hour = 0;
				done = 0;
				ns = hour1;
			end
			
			hour1: begin
				hour = 0;
				done = 0;
				
				if(incrHour)
					ns = hour2;
				else 
					ns = hour1;
			end
			
			hour2: begin
				hour = 1;
				done = 0;
				
				if(incrHour)
					ns = hour3;
				else 
					ns = hour2;
			end
			
			hour3: begin
				hour = 2;
				done = 0;
				
				if(incrHour)
					ns = hour4;
				else 
					ns = hour3;
			end
			
			hour4: begin
				hour = 3;
				done = 0;
				
				if(incrHour)
					ns = hour5;
				else 
					ns = hour4;
			end
			
			hour5: begin
				hour = 4;
				done = 0;
				
				if(incrHour)
					ns = hour6;
				else 
					ns = hour5;
			end
			
			hour6: begin
				hour = 5;
				done = 0;
				
				if(incrHour)
					ns = hour7;
				else 
					ns = hour6;
			end
			
			hour7: begin
				hour = 6;
				done = 0;
				
				if(incrHour)
					ns = hour8;
				else 
					ns = hour7;
			end
			
			hour8: begin
				hour = 7;
				done = 0;
				
				if(incrHour)
					ns = endStats;
				else 
					ns = hour8;
			end
			
			endStats: begin
				hour = 7;
				done = 1;
				
				if(incrHour) begin
					hour = 0;
					ns = hour1;
				end
				else
					ns = endStats;
			end
		endcase
	end
	
	//if reset ps goes to idle state else it goes to ns
	always_ff @(posedge clk) begin
		if(reset) begin
			ps <= idle;
		end else begin
			ps <= ns;
		end
	end
endmodule

//testbench for hourFSM tests all expected, unexpected and edgecase behaviors
module hourFSM_testbench();
	logic clk, reset, incrHour;
	logic entrance_gate, exit_gate;
	logic [2:0] hour;
	logic done;
	
	hourFSM dut (.*);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
	
		reset <= 1; 																		@(posedge clk);
		reset <= 0; entrance_gate <= 0; exit_gate <= 0; hour <= 0; 			@(posedge clk);
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
	   
		reset <= 1;  			             			@(posedge clk); 
	   reset <= 0;                               @(posedge clk); 
		                                          @(posedge clk); 
	 $stop;
	end
endmodule
																