`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 03:20:23
// Design Name: 
// Module Name: tb_aes_axi_top
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


module tb_aes_axi_top;

    reg         clk;
    reg         resetn;
    reg         wvalid;
    reg  [31:0] waddr;
    reg  [31:0] wdata;
    
    // Instantiate the AXI Wrapper
    aes_axi_accelerator uut (
        .S_AXI_ACLK    (clk),
        .S_AXI_ARESETN (resetn),
        .axi_wdata     (wdata),
        .axi_awaddr    (waddr),
        .axi_wvalid    (wvalid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Reset sequence
        resetn = 0; #20; resetn = 1;

        // 1. Write the 128-bit Key to offsets 0x10-0x1C
        wvalid = 1;
        waddr = 32'h10; wdata = 32'h00010203; #10;
        waddr = 32'h14; wdata = 32'h04050607; #10;
        waddr = 32'h18; wdata = 32'h08090a0b; #10;
        waddr = 32'h1C; wdata = 32'h0c0d0e0f; #10;

        // 2. Write the Plaintext to offset 0x20
        waddr = 32'h20; wdata = 32'h00112233; #10;
        
        // 3. Trigger Encryption (Set Start bit in Control Reg at 0x00)
        waddr = 32'h00; wdata = 32'h1; #10;
        wvalid = 0;

        $display("Encryption started. Waiting for completion...");
        wait(uut.slv_reg_status == 32'h0000_0008); // Wait for DONE status
        $display("Encryption complete. Check memory for ciphertext.");
        $finish;
    end
endmodule
