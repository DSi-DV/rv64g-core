/*
Write a markdown documentation for this systemverilog module:
Author : Subhan Zawad Bihan (https://github.com/SubhanBihan)
This file is part of DSInnovators:rv64g-core
Copyright (c) 2024 DSInnovators
Licensed under the MIT License
See LICENSE file in the project root for full license information
*/

module demux #(
    // Parameter to define the number of output lines; default is 8.
    parameter int NUM_OUPUT = 8,

    // Parameter to define the width of each data line; default is 4.
    parameter int DATA_WIDTH = 4
) (
    // Index input used to select which output line to activate.
    input logic [$clog2(NUM_OUPUT)-1:0] index_i,

    // Data input that will be routed to the selected output line.
    input logic [DATA_WIDTH-1:0] data_i,

    // Array of output wires; one of these will hold the input data based on the index.
    output logic [NUM_OUPUT-1:0][DATA_WIDTH-1:0] wire_o
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin : demuxing
    // Initialize all output lines to zero to prevent latches or undesired values.
    wire_o = '0;

    // Assign the input data to the output line specified by the index.
    wire_o[index_i] = data_i;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    // Check if the number of output lines exceeds the supported maximum of 512.
    // This ensures that hardware implementation remains manageable.
    if (NUM_OUPUT > 512) begin
      $error("Output lines exceed 512");
    end
  end
`endif  // SIMULATION

endmodule
