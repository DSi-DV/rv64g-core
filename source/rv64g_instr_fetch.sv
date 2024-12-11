/*
Write a markdown documentation for this systemverilog module:
Author : Subhan Zawad Bihan (https://github.com/SubhanBihan)
This file is part of DSInnovators:rv64g-core
Copyright (c) 2024 DSInnovators
Licensed under the MIT License
See LICENSE file in the project root for full license information
*/

module rv64g_instr_fetch #(
    localparam int XLEN = 64,
    localparam int ILEN = 32,
    localparam type addr_t = logic [XLEN-1:0],
    localparam type instr_t = logic [ILEN-1:0]
) (
    input logic  arst_ni,     // Asynchronous reset, active low
    input logic  clk_i,       // Clock input
    input addr_t boot_addr_i, // Boot address (at reset) input

    output logic   req_o,   // Data/Instr request output
    output addr_t  addr_o,  // pc output
    input  instr_t data_i,  // Data/Instr input
    input  logic   gnt_i,   // data_i grant/valid input

    output addr_t  pc_o,     // pc output
    output instr_t instr_o,  // Instr output (to decoder)
    output logic   valid_o,  // Instr output validity (output)
    input  logic   ready_i,  // Instr output ready (input)

    input  addr_t current_addr_i,   // Current address input
    input  addr_t next_addr_i,      // Next address input
    input  logic  is_jump_i,        // Current-Next validity input
    input  logic  dna_load_i,       // Direct nect address load input
    output logic  pipeline_clear_o  // Output to clear the pipeline
    // is_jump_i dna_load_i
    //  0           0   d
    //  0           1   interrupt
    //  1           0   invalid
    //  1           1   jump

  /*
        valid (1)  c_addr (63:2)      n_addr (63:2)    FIFO clearing
          0                  12            4
          0                 000          000
          0                 000          000
          0                 000          000
          0                 000          000
          0                 000          000

         0  4 8 12  4 8 12  4 8 12  4 8 12 16 20 ...
         0  4 8 12  4 8 12  4 8 12  4 8 12  4 8 12  4 8 12  4 8 12 ...
  */
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // CHANGE THIS TO SUBMODULE (???)
  logic [63:2] current_buffer[256];  // valid (127), xxx, c_addr (123:62),
                                      // n_addr (61:0) FIFO clearing

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  assign addr_o = pc_o;
  assign req_o = ready_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      pc_o <= boot_addr_i;
      // cn_buffer = '0;
    end
    else begin
      if (gnt_i) instr_o <= data_i;
      valid_o <= gnt_i;

      case ({is_jump_i, dna_load_i})
        2'b01: begin  // Interrupt, do not push to buffer
          pc_o <= next_addr_i;
          pipeline_clear_o <= 1'b1;
        end

        2'b11: begin  // Jump/Branch, push to buffer
          pc_o <= next_addr_i;
          pipeline_clear_o <= 1'b1;

        end

        default: begin
          pc_o <= pc_o + 4;
          pipeline_clear_o <= 1'b0;
        end
      endcase
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
