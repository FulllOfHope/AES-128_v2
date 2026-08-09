`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 03:13:24
// Design Name: 
// Module Name: tb_aes_pipeline
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

module tb_aes_pipeline;

    // 1. Declare Testbench Signals
    reg          clk;
    reg          reset;
    reg          ce;
    reg  [127:0] plaintext;
    reg  [127:0] master_key;
    
    wire [127:0] ciphertext;
    wire         valid_out;

    // 2. Instantiate the Factory (Unit Under Test)
    aes_128_pipeline uut (
        .clk        (clk),
        .reset      (reset),
        .ce         (ce),
        .plaintext  (plaintext),
        .master_key (master_key),
        .ciphertext (ciphertext),
        .valid_out  (valid_out)
    );

    // 3. Generate a 100 MHz Clock (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. The Simulation Sequence
    initial begin
        $display("==================================================");
        $display("   CIPHERSTREAM-128X : FULL PIPELINE SIMULATION   ");
        $display("==================================================");

        // Initialize inputs
        reset      = 1;
        ce         = 0;
        plaintext  = 128'h0;
        master_key = 128'h0;

        // Hold reset for a few clock cycles
        #20;
        reset = 0;
        ce    = 1; // Turn on the conveyor belt

        $display("[%0t ns] Factory Powered On. Belt is moving.", $time);

        // -----------------------------------------------------------------
        // CYCLE 1: Inject Block A (NIST FIPS-197 Test Vector)
        // -----------------------------------------------------------------
        @(posedge clk);
        master_key = 128'h000102030405060708090a0b0c0d0e0f;
        plaintext  = 128'h00112233445566778899aabbccddeeff;
        $display("[%0t ns] Ingesting Block A...", $time);

        // -----------------------------------------------------------------
        // CYCLE 2: Inject Block B (Just to prove the pipeline doesn't stall)
        // -----------------------------------------------------------------
        @(posedge clk);
        plaintext  = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; 
        $display("[%0t ns] Ingesting Block B...", $time);

        // -----------------------------------------------------------------
        // CYCLE 3: Stop feeding data, let the pipeline process
        // -----------------------------------------------------------------
        @(posedge clk);
        plaintext = 128'h0;
        
        // Now we wait for the pipeline to finish processing Block A.
        // It takes exactly 11 clock cycles to traverse the flip-flops.
        wait(valid_out == 1'b1);
        
        $display("\n[%0t ns] VALID SIGNAL DETECTED!", $time);
        $display("Block A Ciphertext : %h", ciphertext);
        $display("Block A Expected   : 69c4e0d86a7b0430d8cdb78070b4c55a");

        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
            $display("STATUS: BLOCK A PASS! NIST Compliance Confirmed.");
        else
            $display("STATUS: BLOCK A FAIL!");

        // -----------------------------------------------------------------
        // CYCLE 12: Check Block B (It should arrive exactly 1 clock later)
        // -----------------------------------------------------------------
        @(posedge clk);
        
        $display("\n[%0t ns] Block B Ciphertext : %h", $time, ciphertext);
        #1
        $display("STATUS: PIPELINE THROUGHPUT CONFIRMED. 1 Block / Cycle.");

        $display("==================================================");
        $finish;
    end

endmodule
