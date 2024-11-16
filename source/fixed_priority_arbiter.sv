/*
The fixed_priority_arbiter module manages multiple request signals and grants access based on a
fixed priority system. It ensures that the highest priority request is serviced first, by generating
grant signals for the active request with the highest priority. This is useful in systems where
certain tasks need to be prioritized over others to ensure efficient resource allocation and system
performance. The module is parameterized to handle a configurable number of request signals,
providing flexibility for various applications.
Author : Foez Ahmed (foez.official@gmail.com)
*/

module fixed_priority_arbiter #(
    parameter int NUM_REQ = 4 // Number of requests
) (
    input  logic [NUM_REQ-1:0] req_i, // Request inputs
    output logic [NUM_REQ-1:0] gnt_o  // Grant outputs
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  logic [NUM_REQ-1:0] gnt_found; // Signals to track granted requests

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Calculate gnt_found, which indicates if any higher-priority request has been granted
  assign gnt_found[0] = req_i[0];
  for (genvar i = 1; i < NUM_REQ; i++) begin : g_msb_gnt_found
    assign gnt_found[i] = gnt_found[i-1] | req_i[i];
  end

  // Calculate grant outputs based on the gnt_found signals
  assign gnt_o[0] = req_i[0];
  for (genvar i = 1; i < NUM_REQ; i++) begin : g_msb_gnt
    assign gnt_o[i] = req_i[i] & ~gnt_found[i-1];
  end

endmodule
