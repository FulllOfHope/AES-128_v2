`timescale 1ns / 1ps

module aes_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);

    // Internal wires connecting the assembly line workstations
    wire [127:0] sb_out;
    wire [127:0] sr_out;
    wire [127:0] mc_out;

    // 1. SubBytes: The Non-Linear Dictionary Lookup
    sub_bytes_128 step1_sub_bytes (
        .data_in  (state_in),
        .data_out (sb_out)
    );

    // 2. ShiftRows: The Wire Scrambler
    shift_rows_128 step2_shift_rows (
        .data_in  (sb_out),
        .data_out (sr_out)
    );

    // 3. MixColumns: The GF(2^8) Matrix Multiplier
    mix_columns_128 step3_mix_columns (
        .data_in  (sr_out),
        .data_out (mc_out)
    );

    // 4. AddRoundKey: The 128-bit XOR
    assign state_out = mc_out ^ round_key;

endmodule
