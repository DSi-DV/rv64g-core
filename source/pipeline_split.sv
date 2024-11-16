/*
The pipeline_split module is designed to manage data flow in a pipelined system and split the
processed data into two separate output paths: a main output and a secondary output. It ensures
proper synchronization and data integrity using handshaking signals. The module can handle various
data widths, supports asynchronous reset and synchronous clear signals, and internally instantiates
a pipeline module to process the data while directing the output to multiple destinations.
This allows for efficient and controlled data distribution in hardware designs.
Author : Foez Ahmed (foez.official@gmail.com)
*/

module pipeline_split #(
    parameter int DW = 8  // Data width parameter
) (
    input logic arst_ni,  // Asynchronous reset, active low
    input logic clk_i,    // Clock input
    input logic clear_i,  // Synchronous clear signal

    input  logic [DW-1:0] data_in_i,        // Input data
    input  logic          data_in_valid_i,  // Input data valid signal
    output logic          data_in_ready_o,  // Input data ready signal

    output logic [DW-1:0] data_out_main_o,        // Main output data
    output logic          data_out_main_valid_o,  // Main output data valid signal
    input  logic          data_out_main_ready_i,  // Main output data ready signal

    output logic [DW-1:0] data_out_secondary_o,        // Secondary output data
    output logic          data_out_secondary_valid_o,  // Secondary output data valid signal
    input  logic          data_out_secondary_ready_i   // Secondary output data ready signal
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Internal signals for data and handshake between pipeline stages
  logic [DW-1:0] data_out_o;  // Data output from the internal pipeline
  logic          data_out_valid_o;  // Valid signal for data output from the internal pipeline
  logic          data_out_ready_i;  // Ready signal input for the internal pipeline

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Assign internal pipeline outputs to the main and secondary outputs
  assign data_out_main_o            = data_out_o;
  assign data_out_secondary_o       = data_out_o;

  // Determine if main or secondary output is valid
  assign data_out_main_valid_o      = data_out_valid_o;
  assign data_out_secondary_valid_o = data_out_main_ready_i ? '0 : data_out_valid_o;

  // Combine ready signals from both outputs
  assign data_out_ready_i           = data_out_main_ready_i | data_out_secondary_ready_i;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Instantiate the internal pipeline module
  pipeline #(
      .DW(DW)
  ) u_pipeline (
      .arst_ni,  // Connect asynchronous reset
      .clk_i,  // Connect clock
      .clear_i,  // Connect synchronous clear
      .data_in_i,  // Connect input data
      .data_in_valid_i,  // Connect input data valid signal
      .data_in_ready_o,  // Connect input data ready signal
      .data_out_o,  // Connect data output from pipeline
      .data_out_valid_o,  // Connect data valid output from pipeline
      .data_out_ready_i  // Connect ready input to pipeline
  );

endmodule
