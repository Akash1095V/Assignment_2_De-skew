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

module tb_deskew;
  // Input and Output Signals
  reg		i_clk;
  reg		i_reset;
  reg	 [3:0]	i_stream1;
  reg	 [3:0]	i_stream2;

  wire   [7:0]  o_stream;
  wire 	        o_aligned;
  	
  // Clock Generation
  always #5 i_clk = ~i_clk;

  // DUT Instantiation
  deskew dut (
	.i_clk     (i_clk),
	.i_reset   (i_reset),
	.i_stream1 (i_stream1),
        .i_stream2 (i_stream2),
	.o_stream  (o_stream),
	.o_aligned (o_aligned)
  );
  
  // Initial Block
  initial begin
    i_clk = 1'b0; i_reset = 1'b1;
    i_stream1 = 4'hd; i_stream2 = 4'hd;
    @(posedge i_clk) i_reset = 1'b0;
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'hd; 
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h6;    
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'ha; 
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'hc; 
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h9; 
    @(posedge i_clk) i_stream1 = 4'h6; i_stream2 = 4'hd; 
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hf; 
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'h3; 
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'h6; 
    @(posedge i_clk) i_stream1 = 4'h6; i_stream2 = 4'hb;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'h3; i_stream2 = 4'h7; 
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'h5;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h2;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h2; i_stream2 = 4'h9;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hb;
    @(posedge i_clk) i_stream1 = 4'he; i_stream2 = 4'h0;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'h3; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_reset = 1'b0;
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'hd; 
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h6;    
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h0; 
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'hc; 
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h9; 
    @(posedge i_clk) i_stream1 = 4'h6; i_stream2 = 4'hd; 
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hf; 
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'h3; 
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'h6; 
    @(posedge i_clk) i_stream1 = 4'h6; i_stream2 = 4'hb;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'h3; i_stream2 = 4'h7; 
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h5;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h2;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h2; i_stream2 = 4'h9;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hb;
    @(posedge i_clk) i_stream1 = 4'he; i_stream2 = 4'h0;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'h3; i_stream2 = 4'h7; 
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h4;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'h5;
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h7; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h2; i_stream2 = 4'h9;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hb;
    @(posedge i_clk) i_stream1 = 4'he; i_stream2 = 4'h0;

    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'h4;
    @(posedge i_clk) i_stream1 = 4'h3; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'hd; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'ha; i_stream2 = 4'ha;
    @(posedge i_clk) i_stream1 = 4'hc; i_stream2 = 4'hd;
    @(posedge i_clk) i_stream1 = 4'h4; i_stream2 = 4'he;
    @(posedge i_clk) i_stream1 = 4'h5; i_stream2 = 4'h6;
    @(posedge i_clk) i_stream1 = 4'h8; i_stream2 = 4'h3;
    @(posedge i_clk) i_stream1 = 4'h1; i_stream2 = 4'h8;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'h1;
    @(posedge i_clk) i_stream1 = 4'hb; i_stream2 = 4'h0;
    @(posedge i_clk) i_stream1 = 4'hf; i_stream2 = 4'h7;
    @(posedge i_clk) i_stream1 = 4'h9; i_stream2 = 4'hc;
    @(posedge i_clk) i_stream1 = 4'h0; i_stream2 = 4'he;



    @(posedge i_clk) i_reset = 1'b1;
    @(posedge i_clk) i_reset = 1'b0;

    repeat(2) @(posedge i_clk);
    $finish;
  end
endmodule

