//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  generator.sv
// Description      :  This is the generator class where all the test stimulas
// 		       are generated and given to driver there are directed
// 		       and randomized test in this block for full code
// 		       coverage 
// Inputs           :  Nil 
// Outputs          :  Nil  
//////////////////////////////////////////////////////////////////////////////////////////////

class generator;
  int num_cases  = 120;
  int total_sent = 0;
  event done;
  mailbox #(transaction) gen2drv;

  function new(mailbox #(transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task send(logic [3:0] s1, s2, logic rst = 0);
    transaction tx = new();
    tx.i_stream1 = s1;
    tx.i_stream2 = s2;
    tx.i_reset   = rst;
    gen2drv.put(tx);
    total_sent++;
  endtask

  task send_idle(int n);
    repeat(n) send(4'h1, 4'h1);
  endtask
  
  task run();
    // ── Scenario 1: Spec waveform (timing diagram) ────
    $display("[GEN] --- S1: Spec Waveform (16 cycles) ---");
    send(4'hD, 4'hD);
    send(4'hA, 4'h0);   // s1 gets A first
    send(4'h0, 4'h6);
    send(4'hB, 4'hA);   // s2 gets A → aligned (skew=2)
    send(4'hD, 4'hC);
    send(4'hF, 4'h9);
    send(4'h6, 4'hD);
    send(4'h9, 4'hF);
    send(4'hC, 4'h3);
    send(4'h7, 4'h6);
    send(4'h6, 4'hB);
    send(4'hE, 4'h8);
    send(4'hF, 4'hA);
    send(4'h1, 4'h5);
    send(4'h4, 4'h3);
    send(4'h2, 4'h7);

    // ── Scenario 2: IDLE → BOTH (simultaneous A) ──────
    $display("[GEN] --- S2: IDLE->BOTH, skew=0 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'hA, 4'hA);
    send(4'h3, 4'h5);
    send(4'h7, 4'h9);
    send(4'hF, 4'hC);

    // ── Scenario 3: IDLE → AFIRST, skew=1 ────────────
    $display("[GEN] --- S3: IDLE->AFIRST, skew=1 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'hA, 4'h5);   // s1 gets A → AFIRST
    send(4'h3, 4'hA);   // s2 gets A next cycle → aligned
    send(4'h6, 4'hB);
    send(4'h9, 4'hC);

    // ── Scenario 4: IDLE → BFIRST, skew=1 ────────────
    $display("[GEN] --- S4: IDLE->BFIRST, skew=1 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h5, 4'hA);   // s2 gets A → BFIRST
    send(4'hA, 4'h3);   // s1 gets A next cycle → aligned
    send(4'hB, 4'h7);
    send(4'hC, 4'h2);

    // ── Scenario 5: AFIRST → A1FIRST, skew=2 ─────────
    $display("[GEN] --- S5: AFIRST->A1FIRST, skew=2 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'hA, 4'h2);   // s1 gets A → AFIRST
    send(4'h3, 4'h4);   // s2 not A → A1FIRST
    send(4'h5, 4'hA);   // s2 gets A → aligned
    send(4'h6, 4'h7);
    send(4'h8, 4'h9);

    // ── Scenario 6: BFIRST → B1FIRST, skew=2 ─────────
    $display("[GEN] --- S6: BFIRST->B1FIRST, skew=2 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h2, 4'hA);   // s2 gets A → BFIRST
    send(4'h4, 4'h3);   // s1 not A → B1FIRST
    send(4'hA, 4'h5);   // s1 gets A → aligned
    send(4'h7, 4'h6);
    send(4'h9, 4'h8);

    // ── Scenario 7: s1 A arrived, s2 never → IDLE ────
    $display("[GEN] --- S7: s1 A arrived, s2 never comes ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'hA, 4'h1);   // s1 A → AFIRST
    send(4'h2, 4'h3);   // → A1FIRST
    send(4'h4, 4'h5);   // → back to IDLE
    send_idle(3);

    // ── Scenario 8: s2 A arrived, s1 never → IDLE ────
    $display("[GEN] --- S8: s2 A arrived, s1 never comes ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h1, 4'hA);   // s2 A → BFIRST
    send(4'h3, 4'h2);   // → B1FIRST
    send(4'h5, 4'h4);   // → back to IDLE
    send_idle(3);


    // Scenario 9a: BFIRST - s1 arrives when flag[0]==0
    // Covers: (i_stream1==A) && ~flag[0]  -- was 50%
    // s2 gets A first (BFIRST), then s1 IMMEDIATELY on next cycle
    // so flag[0] has no chance to be set -> ~flag[0] branch taken
    $display("[GEN] --- S9a: BFIRST, s1 arrives flag[0]=0 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h3, 4'hA);   // s2 gets A -> BFIRST, flag[0]=0
    send(4'hA, 4'h5);   // s1 IMMEDIATELY -> (i_stream1==A)&&~flag[0] HIT
    send(4'h6, 4'h7);
    send(4'h8, 4'h9);
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h1, 4'hA);   // s2 -> BFIRST
    send(4'hA, 4'h2);   // s1 immediately -> ~flag[0] branch again
    send(4'h3, 4'h4);

    // Scenario 9b: B1FIRST - s1 arrives when flag[1]==0
    // Covers: (i_stream1==A) && ~flag[1]  -- was 50%
    // s2->BFIRST, s1 misses once->B1FIRST, s1 arrives on
    // the FIRST cycle of B1FIRST before flag[1] gets set
    $display("[GEN] --- S9b: B1FIRST, s1 arrives flag[1]=0 ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h3, 4'hA);   // s2 -> BFIRST
    send(4'h4, 4'h5);   // s1 misses -> B1FIRST, flag[1]=0
    send(4'hA, 4'h6);   // s1 1st cycle of B1FIRST -> ~flag[1] HIT
    send(4'h7, 4'h8);
    send(4'h9, 4'hC);
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h1, 4'hA);   // s2 -> BFIRST
    send(4'h2, 4'h3);   // -> B1FIRST
    send(4'hA, 4'h4);   // s1 first cycle of B1FIRST -> ~flag[1]
    send(4'h5, 4'h6);
    send(4'h7, 4'h8);

    // ── Scenario 9: Reset mid-operation ───────────────
    $display("[GEN] --- S9: Reset mid-operation ---");
    send_idle(2);
    send(4'hA, 4'h3);   // → AFIRST
    send(4'h4, 4'h5);   // → A1FIRST
    send(4'h0, 4'h0, 1); // RESET during A1FIRST
    send_idle(2);
    send(4'hA, 4'hA);   // restart → BOTH
    send(4'hD, 4'hE);
    send(4'hF, 4'h2);


    // ============================================================
    // Coverage closure scenarios - targeting the 3 uncovered branches

    // ============================================================
    // CONDITION COVERAGE CLOSURE
    // The tool reports sub-expression coverage for (A && B).
    // 50% on ~flag[0] means flag[0]==1 case never seen alongside A==A.
    // Each fix below exercises BOTH sides:
    //   TRUE  side: A arrives when flag==0 (first time in state)
    //   FALSE side: A arrives AGAIN when flag==1 (second time in state)
    // ============================================================

    // -- Fix 1: (i_stream2==A) && ~flag[0] in AFIRST ─────────────
    // TRUE  (flag[0]==0): s2=A on 1st cycle of AFIRST
    // FALSE (flag[0]==1): s2=A AGAIN on 2nd cycle of AFIRST
    // AFIRST next_state = (s2==A || flag[0]) ? AFIRST : A1FIRST
    // After s2=A sets flag[0]=1, next_state stays AFIRST.
    // Sending s2=A again exercises s2=A with flag[0]=1 -> FALSE side.
    $display("[GEN] --- Cov Fix 1: (s2==A)&&~flag[0] both sides ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'hA, 4'h3);   // IDLE->AFIRST transition
    send(4'h5, 4'hA);   // AFIRST cy1: flag[0]=0, s2=A -> TRUE side HIT
    send(4'h6, 4'hA);   // AFIRST cy2: flag[0]=1, s2=A -> FALSE side HIT
    send(4'h7, 4'h8);   // AFIRST cy3: flag[0]=1, s2!=A
    send(4'h9, 4'hC);

    // -- Fix 2: (i_stream1==A) && ~flag[0] in BFIRST ─────────────
    // TRUE  (flag[0]==0): s1=A on 1st cycle of BFIRST
    // FALSE (flag[0]==1): s1=A AGAIN on 2nd cycle of BFIRST
    // BFIRST next_state = (s1==A || flag[0]) ? BFIRST : B1FIRST
    // After s1=A sets flag[0]=1, next_state stays BFIRST.
    $display("[GEN] --- Cov Fix 2: (s1==A)&&~flag[0] both sides ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h3, 4'hA);   // IDLE->BFIRST transition
    send(4'hA, 4'h5);   // BFIRST cy1: flag[0]=0, s1=A -> TRUE side HIT
    send(4'hA, 4'h6);   // BFIRST cy2: flag[0]=1, s1=A -> FALSE side HIT
    send(4'h7, 4'h8);   // BFIRST cy3: flag[0]=1, s1!=A
    send(4'h9, 4'hC);

    // -- Fix 3: (i_stream1==A) && ~flag[1] in B1FIRST ────────────
    // TRUE  (flag[1]==0): s1=A on 1st cycle of B1FIRST
    // FALSE (flag[1]==1): s1=A AGAIN on 2nd cycle of B1FIRST
    // B1FIRST next_state = (s1==A || flag[1]) ? B1FIRST : IDLE
    // After s1=A sets flag[1]=1, next_state stays B1FIRST.
    // Path to B1FIRST: s2=A (BFIRST), one non-A cycle (->B1FIRST)
    $display("[GEN] --- Cov Fix 3: (s1==A)&&~flag[1] both sides ---");
    send(4'h0, 4'h0, 1);
    send_idle(2);
    send(4'h3, 4'hA);   // IDLE->BFIRST
    send(4'h4, 4'h5);   // BFIRST: s1!=A, flag[0]=0 -> B1FIRST
    send(4'hA, 4'h6);   // B1FIRST cy1: flag[1]=0, s1=A -> TRUE side HIT
    send(4'hA, 4'h7);   // B1FIRST cy2: flag[1]=1, s1=A -> FALSE side HIT
    send(4'h8, 4'h9);   // B1FIRST cy3: flag[1]=1, s1!=A
    send(4'hC, 4'hD);    // ── Scenario 10: Fully random ─────────────────────
    $display("[GEN] --- S10: Random (%0d cycles) ---", num_cases);
    send(4'h0, 4'h0, 1); // reset before random burst
    send_idle(1);   
    begin : rand_block
    transaction tx;
      repeat(num_cases) begin
	tx = new();
        if(!tx.randomize())
          $fatal(1, "[GEN] Randomization failed!");
        tx.i_reset = 0;
        gen2drv.put(tx);
        total_sent++;
      end
    end
    ->done;
    $display("[GEN] : Done Total Sent = %0d", total_sent);
  endtask  
endclass
