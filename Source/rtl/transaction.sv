//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  transaction.sv
// Description      :  It is a transaction class of the deskew where the
// 	 	       stream1 and stream 2 are randomized to test the
// 	 	       performance of the deskew.sv design. 
// Inputs           :  Nil
// Outputs          :  Nil  
//////////////////////////////////////////////////////////////////////////////////////////////

class transaction;
  // Randomized Inputs of the design 
  rand logic [3:0] i_stream1;
  rand logic [3:0] i_stream2;
       logic       i_reset;
  
  // Outputs to be captured from the design 
  logic [7:0] o_stream;
  logic       o_aligned;

  constraint valid_input { 
    i_stream1 inside {[4'h0 : 4'hF]};
    i_stream2 inside {[4'h0 : 4'hF]};
  }
  
  constraint inject_A {
    i_stream1 dist { 4'hA :/ 20, [4'h0 : 4'h9] :/ 60, [4'hB : 4'hF] :/ 20};  
    i_stream2 dist { 4'hA :/ 20, [4'h0 : 4'h9] :/ 60, [4'hB : 4'hF] :/ 20};
  }

  function void display(string tag = "");
    $display("[%s] : s1 = %0d | s2 = %0d || o_stream = %0d | o_aligned = %0d", tag, i_stream1, i_stream2, o_stream, o_aligned);
  endfunction
endclass
