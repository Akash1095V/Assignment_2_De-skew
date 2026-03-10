//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  monitor.sv
// Description      :  It is the monitor class which recive the signals from
//                     the DUT for every clk and send them to the scoreboard
//                     to evaluate the DUT for performance.  
// Inputs           :  Nil
// Outputs          :  Nil
//////////////////////////////////////////////////////////////////////////////////////////////

class monitor;
  // Declaring the Virtual Interface and IPC  
  mailbox #(transaction) mon2scb;
  virtual deskew_inf vinf;
  int num_cases = 20;
  // Constructor to create the object with the required connections.
  function new(mailbox #(transaction) mon2scb, virtual deskew_inf vinf);
    this.mon2scb = mon2scb;
    this.vinf    = vinf;
  endfunction
  // Task to capture the transaction of the DUT. 
  task run();
    transaction tx;
    repeat(num_cases)begin
      @(vinf.moninf);
      tx = new();
      tx.i_reset = vinf.moninf.i_reset;
      tx.i_stream1 = vinf.moninf.i_stream1;
      tx.i_stream2 = vinf.moninf.i_stream2;
      tx.o_stream  = vinf.moninf.o_stream;
      tx.o_aligned = vinf.moninf.o_aligned;
       
      tx.display("MON");
      mon2scb.put(tx);
    end
    $display("[MON] : Done capturing the %0d transaction", num_cases);
  endtask      
endclass
