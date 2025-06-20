/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

//The buttonPress module deals with the user's key press run for 1 cycle, 
//takes in clk and input(buttonpress) and outputs a extended hold for 1 cycle
module buttonPress (clk, in, out);
	input logic clk, in;
	output logic out;
	
	logic first_q;
	logic internal;
	
	//Uses a shift regsiter to synchronous the input given by 
	//the button press by holding the input(button press) for longer	
	always_ff@(posedge clk) begin
		first_q <= in;
		internal <= first_q;
	end
	
	enum {no_press, hold_press} ps, ns;
	
	//This FSM has two states, no_press and hold_press where if the 
	//state is in no_press and the internal signal is high the next state
	//transitions to hold_press. If the state is in hold_press and the 
	//internal continues to be high it will stay in this state until the 
	//internal signal becomes low. 
	always_comb begin
		case(ps)
			no_press: if(internal) ns = hold_press;
				else ns=no_press;
			hold_press: if(internal) ns = hold_press;
				else ns=no_press;
		endcase
	end
	
	assign out = (ps==no_press && in);
	
	//Updates the current state(ps) with the next state(ns)
	//at every rising clock edge
	always_ff @(posedge clk) begin
		ps <= ns;
	end
	
endmodule //buttonPress

//testbench for buttonPress tests all expected, unexpected and edgecase behaviors
module buttonPress_testbench();
	logic clk, in;
	logic out;
	logic CLOCK_50;
	
	buttonPress dut (.clk(CLOCK_50), .in(in), .out(out));
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	//tests the button being pressed for different periods of time
	initial begin 
		in <= 0; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 0; 			@(posedge CLOCK_50);
		
		in <= 1; 			@(posedge CLOCK_50);
		in <= 0; 			@(posedge CLOCK_50);
		
		in <= 1; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 0; 			@(posedge CLOCK_50);
		
		in <= 1; 			@(posedge CLOCK_50);
		in <= 1; 			@(posedge CLOCK_50);
		in <= 0; 			@(posedge CLOCK_50);
		in <= 0; 			@(posedge CLOCK_50);
	
		$stop;
	end
endmodule 