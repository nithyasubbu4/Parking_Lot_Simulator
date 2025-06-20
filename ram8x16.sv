/*
Nithya Subramanian
March 11th 2025
EE 371 
Lab 6A, Task 2 */

// This module represents an 8x16-bit RAM (Random Access Memory) 
// with 8 memory locations, each capable of storing 4-bit data. 
// It supports both read and write operations based on the provided
// control signals. The RAM is clocked on the rising edge of the clock signal.
// - clock: The clock signal that triggers the read and write operations.
// - data: A 4-bit input data to be written into the memory.
// - rdaddress: A 3-bit address input for selecting the memory location 
//   to be read from.
// - wraddress: A 3-bit address input for selecting the memory location 
//   to be written to.
// - wren: A write enable signal that controls whether data should 
//   be written to the memory.
//
// Outputs:
// - q: A 4-bit output representing the data read from the memory 
//   at the specified read address.

module ram8x16 (
    input logic clock,
    input logic [3:0] data,       
    input logic [2:0] rdaddress,  
    input logic [2:0] wraddress,  
    input logic wren,             
    output logic [3:0] q          
);
    logic [3:0] mem [0:7];

    always_ff @(posedge clock) begin
        if (wren)
            mem[wraddress] <= data;
    end

    assign q = mem[rdaddress];

endmodule
