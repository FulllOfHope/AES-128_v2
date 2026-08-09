`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 02:49:27
// Design Name: 
// Module Name: test_sub_bytes
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_sub_bytes;

    // Testbench signals
    reg  [127:0] data_in;
    wire [127:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    sub_bytes_128 uut (
        .data_in(data_in), 
        .data_out(data_out)
    );

    initial begin
        // Print a header to the console
        $display("========================================");
        $display("   AES-128 SUB-BYTES SIMULATION START   ");
        $display("========================================");

        // TEST VECTOR 1: All Zeros
        // According to the S-Box, 0x00 should become 0x63. 
        // So 16 bytes of 0x00 should output 16 bytes of 0x63.
        data_in = 128'h00000000_00000000_00000000_00000000;
        #10; 
        $display("Test 1 - Input : %h", data_in);
        $display("Test 1 - Output: %h", data_out);
        if (data_out === 128'h63636363_63636363_63636363_63636363)
            $display("Test 1: PASS!");
        else
            $display("Test 1: FAIL!");

        $display("----------------------------------------");

        // TEST VECTOR 2: FIPS-197 Appendix B Example (Round 1 Input)
        data_in = 128'h193de3bea0f4e22b9ac68d2ae9f84808;
        #10;
        $display("Test 2 - Input : %h", data_in);
        $display("Test 2 - Output: %h", data_out);
        // Expected output from FIPS manual
        if (data_out === 128'hd42711aee0bf98f1b8b45de51e415230)
            $display("Test 2: PASS!");
        else
            $display("Test 2: FAIL!");

        $display("========================================");
        $finish; // End the simulation
    end

endmodule
