`timescale 1ns / 1ps

module mix_columns_128 (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // Instantiate 4 parallel MixColumn blocks (32 bits each)
    // AES organizes data in column-major order.
    
    mix_column col_0 (
        .col_in  (data_in[127:96]),
        .col_out (data_out[127:96])
    );
    
    mix_column col_1 (
        .col_in  (data_in[95:64]),
        .col_out (data_out[95:64])
    );
    
    mix_column col_2 (
        .col_in  (data_in[63:32]),
        .col_out (data_out[63:32])
    );
    
    mix_column col_3 (
        .col_in  (data_in[31:0]),
        .col_out (data_out[31:0])
    );

endmodule
