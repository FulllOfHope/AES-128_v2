`timescale 1ns / 1ps

module aes_round_final (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);

    wire [127:0] sb_out;
    wire [127:0] sr_out;

    // 1. SubBytes
    sub_bytes_128 step1_sub_bytes (
        .data_in  (state_in),
        .data_out (sb_out)
    );

    // 2. ShiftRows
    shift_rows_128 step2_shift_rows (
        .data_in  (sb_out),
        .data_out (sr_out)
    );

    // No MixColumns in the 10th round!
    
    // 3. AddRoundKey
    assign state_out = sr_out ^ round_key;

endmodule
