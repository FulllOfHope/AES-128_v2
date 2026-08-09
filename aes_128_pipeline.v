`timescale 1ns / 1ps

module aes_128_pipeline (
    input  wire         clk,
    input  wire         reset,
    input  wire         ce,          // Clock Enable (AXI Backpressure Stall)
    input  wire [127:0] plaintext,
    input  wire [127:0] master_key,
    output reg  [127:0] ciphertext,
    output reg          valid_out
);

    // Arrays to hold the data and keys at each stage of the pipeline
    // [0] is the input stage, [10] is the final output stage
    reg  [127:0] stage_data [0:10];
    reg  [127:0] stage_key  [0:10];
    reg          stage_valid[0:10]; 

    // Wires for the combinational logic between flip-flops
    wire [127:0] next_data [1:10];
    wire [127:0] next_key  [1:10];

    // The 10 AES Round Constants (RCON)
    wire [7:0] rcon [1:10];
    assign rcon[1] = 8'h01; assign rcon[2] = 8'h02; assign rcon[3] = 8'h04;
    assign rcon[4] = 8'h08; assign rcon[5] = 8'h10; assign rcon[6] = 8'h20;
    assign rcon[7] = 8'h40; assign rcon[8] = 8'h80; assign rcon[9] = 8'h1B;
    assign rcon[10]= 8'h36;

    // =========================================================================
    // INITIAL STAGE (Cycle 0): AddRoundKey (Pre-whitening)
    // =========================================================================
    always @(posedge clk) begin
        if (reset) begin
            stage_valid[0] <= 1'b0;
        end else if (ce) begin
            stage_data[0]  <= plaintext ^ master_key; // Initial XOR
            stage_key[0]   <= master_key;
            stage_valid[0] <= 1'b1; // In a real system, driven by an input 'valid' signal
        end
    end

    // =========================================================================
    // STAGES 1 to 9: Standard AES Rounds + Key Expansion
    // =========================================================================
    genvar i;
    generate
        for (i = 1; i <= 9; i = i + 1) begin : pipeline_stages
            
            // Combinational Workstation
            aes_round encrypt_round (
                .state_in  (stage_data[i-1]),
                .round_key (next_key[i]),
                .state_out (next_data[i])
            );

            // Combinational Key Scheduler
            aes_key_expand_round key_expand (
                .key_in  (stage_key[i-1]),
                .rcon    (rcon[i]),
                .key_out (next_key[i])
            );

            // The Conveyor Belt (Flip-Flops)
            always @(posedge clk) begin
                if (reset) begin
                    stage_valid[i] <= 1'b0;
                end else if (ce) begin
                    stage_data[i]  <= next_data[i];
                    stage_key[i]   <= next_key[i];
                    stage_valid[i] <= stage_valid[i-1];
                end
            end
        end
    endgenerate

    // =========================================================================
    // STAGE 10: Final AES Round (No MixColumns) + Final Key Expansion
    // =========================================================================
    aes_round_final final_encrypt_round (
        .state_in  (stage_data[9]),
        .round_key (next_key[10]),
        .state_out (next_data[10])
    );

    aes_key_expand_round final_key_expand (
        .key_in  (stage_key[9]),
        .rcon    (rcon[10]),
        .key_out (next_key[10])
    );

    always @(posedge clk) begin
        if (reset) begin
            valid_out <= 1'b0;
        end else if (ce) begin
            ciphertext <= next_data[10];
            valid_out  <= stage_valid[9];
        end
    end

endmodule
