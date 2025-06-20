/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

//Takes in the address with a 4-bit input signal and outputs a converted 
//7-seg 7-bit signal for the number that is inputed.
module hexDisplay (address, hex);
	input  logic [3:0] address;
	output logic [6:0] hex;
	
	always_comb begin
		case (address)
  
			0: hex = 7'b1000000; //0
			1: hex = 7'b1111001; //1
			2: hex = 7'b0100100; //2
			3: hex = 7'b0110000; //3
			4: hex = 7'b0011001; //4
			5: hex = 7'b0010010; //5
			6: hex = 7'b0000010; //6
			7: hex = 7'b1111000; //7
			8: hex = 7'b0000000; //8
			9: hex = 7'b0010000; //9
			10: hex = 7'b0001000; //A
			11: hex = 7'b0000011; //b
			12: hex = 7'b1000110; //C
			13: hex = 7'b0100001; //d 
			14: hex = 7'b0000110; //E
			15: hex = 7'b0001110; //F
      endcase
	end  
endmodule  

// hexDisplay_testbench simulates all scenarios
module hexDisplay_testbench();
   logic [3:0] address;
   logic [6:0] hex; 
	
	
	hexDisplay dut(.address, .hex);
	
	initial begin
		address = 4'b0001;   #10; //1
		address = 4'b0010;   #10; //2
		address = 4'b0011;   #10; //3
	   address = 4'b0100;   #10; //4
		address = 4'b0101;   #10; //5
		address = 4'b0110;   #10; //6
		address = 4'b0111;   #10; //7
		address = 4'b1000;   #10; //8
		address = 4'b1001;   #10; //9
		address = 4'b1010;   #10; //10
		$stop();
	end
	
endmodule
