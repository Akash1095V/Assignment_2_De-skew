//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  environment.sv
// Description      :  This is the environment class of the Test bench it
// 		       controls generator, driver, monitor and scoreboard of
// 		       the Test bech.  
// Inputs           :  Nil
// Outputs          :  Nil
//////////////////////////////////////////////////////////////////////////////////////////////

class environment;
  // All the handles of the internal components
  generator  gen;
  driver     drv;
  monitor    mon;
  scoreboard scb;

  mailbox #(transaction) gen2drv, mon2scb;
  virtual deskew_inf vinf;

  int num_cases = 240;
  
  function new(virtual deskew_inf vinf);
    this.vinf = vinf;
    gen2drv = new();
    mon2scb = new();
    gen = new(gen2drv);
    drv = new(gen2drv, vinf);
    mon = new(mon2scb, vinf);
    scb = new(mon2scb);
  endfunction

  task set_num_cases(int n);
    num_cases = n;
    mon.num_cases = n;
    scb.num_cases = n;
    drv.num_cases = n;
    gen.num_cases = n;
  endtask

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join
    #50;
    $display("[ENV] Done");
  endtask
endclass
