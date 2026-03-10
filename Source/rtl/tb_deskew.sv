//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  tb_deskew.sv
// Description      :  tb_deskew is the testbench module used to verify the functionality of
// 		       the deskew design. It generates the clock and reset, applies various 
// 		       input patterns to i_stream1 and i_stream2 (including skewed arrivals of
// 		       4'hA), and observes the outputs o_stream and o_aligned. The testbench 
// 		       checks whether the DUT correctly aligns the two input streams within 
// 		       the allowed skew, produces the expected concatenated output (especially
// 		       the first 0xAA), and asserts the alignment flag at the proper time.
// Inputs           :  NIL
// Outputs          :  NIL
//////////////////////////////////////////////////////////////////////////////////////////////

// Including the testbench components
`include "transaction.sv"
`include "deskew_inf.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

module tb_deskew;
  logic i_clk;
  // initilizing the clk
  initial i_clk = 0;
  // Clock Generation
  always #5 i_clk = ~i_clk;
  
  deskew_inf inf (.clk(i_clk));
  // DUT Instantiation
  deskew dut (
	.i_clk     (i_clk),
	.i_reset   (inf.i_reset),
	.i_stream1 (inf.i_stream1),
        .i_stream2 (inf.i_stream2),
	.o_stream  (inf.o_stream),
	.o_aligned (inf.o_aligned)
  );

  initial begin
    test t; 
    t = new(inf);
    t.run();
    #20;
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_deskew);
  end
endmodule
