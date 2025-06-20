/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

//a counter that divides a given clock input and outputs
//a divided_clocks output that is 32-bits. 
module clock_divider(clock, divided_clocks); 
	input logic clock; 
	output logic [31:0] divided_clocks = 0; 
 
   always_ff @(posedge clock) begin 
      divided_clocks <= divided_clocks + 1; 
   end 
 
endmodule

module clock_divider_testbench(); 
   logic clock; 
   logic [31:0] divided_clocks;
   
	`timescale 1 ps / 1 ps
	
   clock_divider dut(.clock, .divided_clocks);
	
	initial begin
	   @(posedge clock);
		@(posedge clock);
	
	end
endmodule
