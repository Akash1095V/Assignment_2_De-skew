//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  generator.sv
// Description      :  Fully randomized generator class - all scenarios driven by
//                     constrained random stimulus for maximum coverage
// Inputs           :  Nil
// Outputs          :  Nil
//////////////////////////////////////////////////////////////////////////////////////////////

class generator;
  int num_cases  = 500;
  int total_sent = 0;
  event done;
  int r1 = 0;
  mailbox #(transaction) gen2drv;

  // Constructor
  function new(mailbox #(transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  // Basic send task
  task send(logic [3:0] s1, s2, logic rst = 0);
    transaction tx = new();
    tx.i_stream1 = s1;
    tx.i_stream2 = s2;
    tx.i_reset   = rst;
    gen2drv.put(tx);
    total_sent++;
  endtask
  
  // Sending reset + random IDLE cycles
  task send_reset(int idle_cycles = 2);
    send(4'h0, 4'h0, 1);
    repeat(idle_cycles) begin
      transaction tx;
      tx = new();
      if(!tx.randomize() with {i_stream1 != 4'hA; i_stream2 != 4'hA;})
        $fatal(1, "[GEN] : IDLE randomization failed!");
      tx.i_reset = 0;
      gen2drv.put(tx);
      total_sent++;
    end
  endtask
  
  // Send Random task 
  task send_random();
    transaction tx;
    tx = new();
    if(!tx.randomize()) 
      $fatal(1, "[GEN] : randomization failed!");
    tx.i_reset = 0;
    gen2drv.put(tx);
    total_sent++;
  endtask

  // Randomization for BOTH case
  task send_both_A();
    transaction tx;
    tx = new();
    if(!tx.randomize() with {i_stream1 == 4'hA; i_stream2 == 4'hA;}) 
      $fatal(1, "[GEN] : BOTH case randomization failed!");
    tx.i_reset = 0;
    gen2drv.put(tx);
    total_sent++;
  endtask

  // Randomization for AFIRST case
  task send_s1_A();
    transaction tx;
    tx = new();
    if(!tx.randomize() with {i_stream1 == 4'hA; i_stream2 != 4'hA;}) 
      $fatal(1, "[GEN] : s1-A randomization failed!");
    tx.i_reset = 0;
    gen2drv.put(tx);
    total_sent++;
  endtask

  // Randomization for BFIRST case
  task send_s2_A();
    transaction tx;
    tx = new();
    if(!tx.randomize() with {i_stream1 != 4'hA; i_stream2 == 4'hA;}) 
      $fatal(1, "[GEN] : s2-A randomization failed!");
    tx.i_reset = 0;
    gen2drv.put(tx);
    total_sent++;
  endtask
  
  // Random send with neither streams with A
  task send_no_A();
    transaction tx;
    tx = new();
    if(!tx.randomize() with {i_stream1 != 4'hA; i_stream2 != 4'hA;}) 
      $fatal(1, "[GEN] : no-A randomization failed!");
    tx.i_reset = 0;
    gen2drv.put(tx);
    total_sent++;
  endtask

  // Main task to run - all scenarios
  task run();
    // Scenario 1: IDLE to BOTH (skew = 0)
    $display("[GEN] : S1 : IDLE -> BOTH skew = 0");
    repeat(3) begin
      send_reset(3);
      send_both_A();
      repeat(5) send_random();
    end

    // Scenario 2: IDLE to AFIRST (skew = 1)
    $display("[GEN] : S2 : IDLE -> AFIRST skew = 1");
    repeat(3) begin
      send_reset(3);
      send_s1_A();
      send_s2_A();
      repeat(5) send_random();
    end

    // Scenario 3: IDLE to AFIRST to A1FIRST (skew = 2)
    $display("[GEN] : S3 : IDLE -> AFIRST skew = 1");
    repeat(3) begin
      send_reset(3);
      send_s1_A();
      send_no_A();
      send_s2_A();
      repeat(5) send_random();
    end
    
    // Scenario 4: IDLE to BFIRST (skew = 1)
    $display("[GEN] : S4 : IDLE -> BFIRST skew = 1");
    repeat(3) begin
      send_reset(3);
      send_s2_A();
      send_s1_A();
      repeat(5) send_random();
    end

    // Scenario 5: IDLE to BFIRST to B1FIRST (skew = 2)
    $display("[GEN] : S5 : IDLE -> AFIRST skew = 1");
    repeat(3) begin
      send_reset(3);
      send_s2_A();
      send_no_A();
      send_s1_A();
      repeat(5) send_random();
    end

    // Scenario 6: s1 arrived but s2 never
    $display("[GEN] : S6 : s1 arrives but s2 never");
    repeat(3) begin
      send_reset(3);
      send_s1_A();
      send_no_A();
      send_no_A();
      repeat(5) send_random();
    end

    // Scenario 7: s2 arrives but s1 never
    $display("[GEN] : S7 : s2 arrives but s1 never");
    repeat(3) begin
      send_reset(3);
      send_s2_A();
      send_no_A();
      send_no_A();
      repeat(5) send_random();
    end

    // Scenario 8: Reset mid-operation
    $display("[GEN] : S8 : Reset mid operation");
    repeat(5) begin
      send_reset(3);
      if($urandom_range(0,1)) send_s1_A();
      else 		      send_s2_A();
      repeat(2) send_random();
      send_reset(2);
      repeat(4) send_random();
    end

    // Scenario 9: Coverage for flag[0]
    $display("[GEN] : S9 : flag[0] coverage randomization");
    repeat(4) begin
      send_reset(3);
      send_s1_A();
      send_s2_A();
      send_s2_A();
      repeat(3) send_random();
      send_reset(3);
      send_s2_A();
      send_s1_A();
      send_s1_A();
      repeat(3) send_random();
    end

    // Scenario 10: Coverage for flag[1]
    $display("[GEN] : S10 : flag[1] coverage randomization");
    repeat(4) begin
      send_reset(3);
      send_s1_A();
      send_no_A();
      send_s2_A();
      send_s2_A();
      repeat(3) send_random();
      send_reset(3);
      send_s2_A();
      send_no_A();
      send_s1_A();
      send_s1_A();
      repeat(3) send_random();
    end

    // Scenario 11: Fully randomized burst
    $display("[GEN] : S11 : Fully random burst");
    send_reset(1);
    repeat(num_cases) begin
      transaction tx;
      tx = new();
      if(r1%8 == 0) send_reset(2);
      if(!tx.randomize()) $fatal(1, "[GEN] : Fully randomization packet failed!");
      tx.i_reset = 0;
      gen2drv.put(tx);
      total_sent++;
    end
    ->done;
    $display("[GEN] : Done Total Sent = %0d", total_sent);
  endtask
endclass
