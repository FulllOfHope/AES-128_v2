`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 02:58:30
// Design Name: 
// Module Name: tb_aes_round
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


`timescale 1ns / 1ps

module tb_aes_round;

    // Testbench signals
    reg  [127:0] state_in;
    reg  [127:0] round_key;
    wire [127:0] state_out;

    // Instantiate the Unit Under Test (UUT)
    aes_round uut (
        .state_in  (state_in), 
        .round_key (round_key), 
        .state_out (state_out)
    );

    initial begin
        $display("========================================");
        $display("   AES-128 FULL ROUND SIMULATION START  ");
        $display("========================================");

        // TEST VECTOR: FIPS-197 Appendix B (Round 1)
        // 1. The data entering Round 1 (after the initial AddRoundKey)
        state_in  = 128'h193de3bea0f4e22b9ac68d2ae9f84808;
        
        // 2. The 128-bit Key for Round 1
        round_key = 128'ha0fafe1788542cb123a339392a6c7605;
        
        // Wait for combinational logic to propagate
        #10;
        
        $display("Input State  : %h", state_in);
        $display("Round Key    : %h", round_key);
        $display("Output State : %h", state_out);
        $display("Expected     : a49c7ff2689f352b6b5bea43c6369dc0");
        
        // 3. The Expected output at the very end of Round 1
        if (state_out === 128'ha49c7ff2689f352b6b5bea43c6369dc0)
            $display("\nSTATUS: PASS! Your encryption engine is flawless.");
        else
            $display("\nSTATUS: FAIL! Check the internal wiring.");
            
        $display("========================================");
        $finish;
    end

endmodule
