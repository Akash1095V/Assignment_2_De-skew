//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  deskew_inf.sv
// Description      :  Interface of the deskew DUT. This is used virtually to
// 		       connect the dynamic objects to the static DUT.  
// Inputs           :  i_reset, i_stream1, i_stream2, o_stream, o_aligned
// Outputs          :  i_reset, i_stream1, i_stream2
//////////////////////////////////////////////////////////////////////////////////////////////

interface deskew_inf(
	input logic clk
);
  logic       i_reset;
  logic [3:0] i_stream1;
  logic [3:0] i_stream2;
  logic [7:0] o_stream;
  logic       o_aligned;
  // Driver to DUT interface
  clocking drvinf @(posedge clk);
    output i_reset;
    output i_stream1; 
    output i_stream2;
  endclocking
  // Monitor to DUT interface
  clocking moninf @(posedge clk);
    input i_reset;
    input i_stream1;
    input i_stream2;
    input o_stream;
    input o_aligned;
  endclocking
endinterface
