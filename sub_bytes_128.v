`timescale 1ns / 1ps

module sub_bytes_128 (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // Instantiate 16 parallel S-Boxes using a generate block
    // This processes all 16 bytes of the AES state simultaneously
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sbox_array
            aes_sbox sbox_inst (
                // Extract 8 bits (1 byte) at a time from the 128-bit input
                .in_byte  (data_in[(i*8)+7 : (i*8)]), 
                
                // Pack the 8-bit output back into the 128-bit output vector
                .out_byte (data_out[(i*8)+7 : (i*8)])
            );
        end
    endgenerate

endmodule
