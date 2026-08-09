`timescale 1ns / 1ps

//In Galois Field GF(2^8), addition is simply an XOR gate. 
//While, multiplication by 2 is a bitwise Left Shift, but if the MSB is a 1, 
//XOR the result with the 0x1b. 

module mix_column (
    input  wire [31:0] col_in,   // 4 bytes in
    output wire [31:0] col_out   // 4 bytes out
);

    // split the 32-bit input into 4 individual bytes
    wire [7:0] s0 = col_in[31:24];
    wire [7:0] s1 = col_in[23:16];
    wire [7:0] s2 = col_in[15:8];
    wire [7:0] s3 = col_in[7:0];

    // The GF(2^8) multiply-by-2 function (xtime)
    // If the top bit [7] is 1, shift and XOR with 0x1B. Otherwise, just shift.
    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7]) ? ((b << 1) ^ 8'h1B) : (b << 1);
        end
    endfunction

    // Execute the Matrix Multiplication using our xtime function and XOR gates
    // For multiply by 3, 3 = 2 + 1, so we can multiply by 2 ^ x
    // Out0 = (2*s0) ^ (3*s1) ^ (1*s2) ^ (1*s3)
    assign col_out[31:24] = xtime(s0) ^ (xtime(s1) ^ s1) ^ s2 ^ s3;
    
    // Out1 = (1*s0) ^ (2*s1) ^ (3*s2) ^ (1*s3)
    assign col_out[23:16] = s0 ^ xtime(s1) ^ (xtime(s2) ^ s2) ^ s3;
    
    // Out2 = (1*s0) ^ (1*s1) ^ (2*s2) ^ (3*s3)
    assign col_out[15:8]  = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3) ^ s3);
    
    // Out3 = (3*s0) ^ (1*s1) ^ (1*s2) ^ (2*s3)
    assign col_out[7:0]   = (xtime(s0) ^ s0) ^ s1 ^ s2 ^ xtime(s3);

endmodule
