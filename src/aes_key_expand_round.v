`timescale 1ns / 1ps


module aes_key_expand_round (
    input  wire [127:0] key_in,
    input  wire [7:0]   rcon,     // Round Constant (Unique to each round)
    output wire [127:0] key_out
);

    // Split the 128-bit input key into 4 words (32 bits each)
    wire [31:0] w0 = key_in[127:96];
    wire [31:0] w1 = key_in[95:64];
    wire [31:0] w2 = key_in[63:32];
    wire [31:0] w3 = key_in[31:0];

    // RotWord: Take the last word (w3) and cyclically shift it left by 1 byte
    wire [31:0] rot_word = {w3[23:0], w3[31:24]};

    // SubWord: Pass the rotated word through 4 S-Boxes
    wire [31:0] sub_word;
    aes_sbox sbox_0 (.in_byte(rot_word[31:24]), .out_byte(sub_word[31:24]));
    aes_sbox sbox_1 (.in_byte(rot_word[23:16]), .out_byte(sub_word[23:16]));
    aes_sbox sbox_2 (.in_byte(rot_word[15:8]),  .out_byte(sub_word[15:8]));
    aes_sbox sbox_3 (.in_byte(rot_word[7:0]),   .out_byte(sub_word[7:0]));

    // XOR with Rcon (Only affects the top byte of the word)
    wire [31:0] rcon_word = {rcon, 24'h000000};
    wire [31:0] temp      = sub_word ^ rcon_word;

    // Generate the 4 new words for the next key
    wire [31:0] w4 = w0 ^ temp;
    wire [31:0] w5 = w1 ^ w4;
    wire [31:0] w6 = w2 ^ w5;
    wire [31:0] w7 = w3 ^ w6;

    // Concatenate the 4 new words to form the 128-bit output key
    assign key_out = {w4, w5, w6, w7};

endmodule
