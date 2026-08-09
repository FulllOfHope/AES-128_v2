`timescale 1ns / 1ps

module aes_axi_accelerator (
    // Standard AXI4-Lite Clock and Reset
    input  wire        S_AXI_ACLK,
    input  wire        S_AXI_ARESETN,

    // AXI Write Channels (Input to Hardware)
    input  wire [31:0] axi_wdata,
    input  wire [31:0] axi_awaddr,
    input  wire        axi_wvalid,
    
    // AXI Read Channels (Output from Hardware - THIS PREVENTS DELETION)
    input  wire [31:0] axi_araddr,
    input  wire        axi_arvalid,
    output reg  [31:0] axi_rdata,
    output reg         axi_rvalid
);
    
  

    // =========================================================
    // 1. MEMORY MAPPED REGISTERS
    // =========================================================
    reg [31:0] slv_reg_control;
    reg [31:0] slv_reg_status;
    reg [127:0] master_key_reg;
    reg [127:0] plaintext_reg;
    wire [127:0] ciphertext_wire;
    wire         aes_valid_out;

    // AXI Write Logic (CPU writing to your hardware)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg_control <= 0;
            slv_reg_status  <= 32'h0000_0001; // IDLE State
        end else if (axi_wvalid) begin
            case (axi_awaddr[7:0])
                8'h00: slv_reg_control         <= axi_wdata;
                8'h10: master_key_reg[127:96]  <= axi_wdata;
                8'h14: master_key_reg[95:64]   <= axi_wdata;
                8'h18: master_key_reg[63:32]   <= axi_wdata;
                8'h1C: master_key_reg[31:0]    <= axi_wdata;
                8'h20: plaintext_reg[127:96]   <= axi_wdata;
                8'h24: plaintext_reg[95:64]    <= axi_wdata;
                8'h28: plaintext_reg[63:32]    <= axi_wdata;
                8'h2C: plaintext_reg[31:0]     <= axi_wdata;
            endcase
        end
    end
// =========================================================
    // 3. AXI READ LOGIC (FPGA -> CPU)
    // =========================================================
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rdata  <= 32'h0;
            axi_rvalid <= 1'b0;
        end else if (axi_arvalid) begin
            axi_rvalid <= 1'b1; // Acknowledge the read request
            case (axi_araddr[7:0])
                8'h04: axi_rdata <= slv_reg_status;
                8'h30: axi_rdata <= ciphertext_wire[127:96];
                8'h34: axi_rdata <= ciphertext_wire[95:64];
                8'h38: axi_rdata <= ciphertext_wire[63:32];
                8'h3C: axi_rdata <= ciphertext_wire[31:0];
                default: axi_rdata <= 32'h0;
            endcase
        end else begin
            axi_rvalid <= 1'b0;
        end
    end
    // =========================================================
    // 2. THE BACKPRESSURE ENGINE (The `ce` wire)
    // =========================================================
    // The PS demands: "No pipeline stalls in steady-state, but 
    // correct handling of backpressure."
    
    // If the CPU hasn't read the last block yet, or the AXI bus 
    // says "WAIT", we drop `ce` to 0. 
    wire pipeline_ce;
    
    // Example Backpressure Logic:
    // Only move the belt if the Start bit is 1 AND the AXI bus isn't congested.
    assign pipeline_ce = (slv_reg_control[0] == 1'b1) ? 1'b1 : 1'b0;

    // =========================================================
    // 3. INSTANTIATING YOUR FACTORY
    // =========================================================
    aes_128_pipeline CIPHERSTREAM_CORE (
        .clk        (S_AXI_ACLK),
        .reset      (~S_AXI_ARESETN),
        .ce         (pipeline_ce),       // The critical stall wire
        .plaintext  (plaintext_reg),
        .master_key (master_key_reg),
        .ciphertext (ciphertext_wire),
        .valid_out  (aes_valid_out)
    );

    // =========================================================
    // 4. STATUS UPDATES
    // =========================================================
    always @(posedge S_AXI_ACLK) begin
        if (aes_valid_out) begin
            slv_reg_status <= 32'h0000_0008; // DONE state
        end else if (pipeline_ce) begin
            slv_reg_status <= 32'h0000_0002; // BUSY state
        end
    end

endmodule