/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */


//Counter takes in two 1-bit inputs called clk and reset and returns a 2-bit value called
//out. It cycles through the "hours" 0 - 7 and resets to 0 a either after the 7th hour
//or when reset signal is high
module counter (clk, reset, out);
		
	input logic clk, reset;
	output logic [2:0] out;
	
	always_ff @(posedge clk) begin
		if(reset) begin
			out <= 0;
		end else begin
			if(out < 7) begin
				out <= out + 1;
			end else begin
				out <= 0;
			end
		end
	end
endmodule

//testbench for counter tests all expected, unexpected and edgecase behaviors
module counter_testbench ();
	logic clk, reset;
	logic [2:0] out;
	
	counter dut (.clk(clk), .reset(reset), .out(out));
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin 
		reset <= 1;					@(posedge clk);
										@(posedge clk);
		reset <= 0;					@(posedge clk);
										@(posedge clk);
										@(posedge clk);										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		reset <= 1;					@(posedge clk);
		reset <= 0; 				@(posedge clk);
										@(posedge clk);
		$stop();
	end
endmodule 