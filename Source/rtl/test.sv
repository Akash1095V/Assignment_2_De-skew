//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  test.sv
// Description      :  It is the main class which has the environment in it
//                     and all the process happens here.  
// Inputs           :  Nil
// Outputs          :  Nil
//////////////////////////////////////////////////////////////////////////////////////////////

class test;
  environment env;
  virtual deskew_inf vinf;
  
  // For Deep-copy Custom constructor. 
  function new(virtual deskew_inf vinf);
    this.vinf = vinf;
    env = new(vinf);
  endfunction

  // Testing the DUT on different scenarios.
  task run();
    $display("[TEST] De-skew Test Bench with Directed and Randomized tests");

    env.set_num_cases(500);
    env.run();

    $display("[TEST] Completed.");
  endtask
endclass
