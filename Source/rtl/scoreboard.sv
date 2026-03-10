//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  scoreboard.sv
// Description      :  It is the scoreboard class which recive the signals from
//                     monitor for every clk and compute the results and
//                     compare them and gives out the pass count and fail
//                     count to determine the performance of the DUT.  
// Inputs           :  Nil
// Outputs          :  Nil
//////////////////////////////////////////////////////////////////////////////////////////////

class scoreboard;
  
  // IPC for monitor to scoreboard communication
  mailbox #(transaction) mon2scb;
  int num_cases = 20;
  
  // Counters to keep a track of no of pass test cases and failed test cases.
  int pass_count = 0;
  int fail_count = 0;
  
  // Same states as the design 
  localparam IDLE    = 3'd0,
	     BOTH    = 3'd1,
	     AFIRST  = 3'd2,
	     BFIRST  = 3'd3,
	     A1FIRST = 3'd4,
	     B1FIRST = 3'd5;
  
  // Extra registers to compute the expected output
  reg [2:0] ref_state = IDLE;
  reg [3:0] ref_buff [1:0];
  reg [1:0] ref_flag  = 2'd0; 
  
  // Expected output containers
  logic [7:0] exp_ostream;
  logic       exp_aligned;

  // Parameterized constructor to make Deep copy 
  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
    ref_buff[0]  = 4'd0;
    ref_buff[1]  = 4'd0;
  endfunction
  
  // Function to compute the expected output
  function automatic void ref_output(
	  input  logic [2:0] state,
	  input  logic [3:0] s1, s2,
	  input  logic [1:0] flag,
	  input  logic [3:0] buf0, buf1,
	  output logic [7:0] ostream,
	  output logic       aligned
  );
    ostream = 8'd0;
    aligned = 1'd0;

    case(state)
      IDLE: begin                             //IDLE outputs
	ostream = 8'h00;
	aligned = 0;
	if(s1 == 4'hA && s2 == 4'hA) begin
          ostream = {s1,s2};
	  aligned = 1;
        end
      end
      BOTH: begin                             //BOTH outputs
	aligned = 1;
	ostream = {s1, s2};
      end
      AFIRST: begin                           //S1 got A first state outputs
	if(s2 == 4'hA && flag[0] == 0) begin
          aligned = 1;
	  ostream = {s2, 4'hA};
        end else if(flag[0]) begin
	  aligned = 1;
          ostream = {s2, buf0};
        end
      end
      BFIRST: begin                           //S2 got A first state outputs
	if(s1 == 4'hA && flag[0] == 0) begin
          aligned = 1;
	  ostream = {s1, 4'hA};
        end else if(flag[0]) begin
	  aligned = 1;
          ostream = {s1, buf0};
        end
      end
      A1FIRST: begin                           //S1 got A and skew is 2 O/Ps
	if(s2 == 4'hA && flag[1] == 0) begin
          aligned = 1;
	  ostream = {s2, 4'hA};
        end else if(flag[1]) begin
	  aligned = 1;
          ostream = {s2, buf1};
        end
      end
      B1FIRST: begin                            // S2 got A and skew is 2 O/Ps
	if(s1 == 4'hA && flag[1] == 0) begin
          aligned = 1;
	  ostream = {s1, 4'hA};
        end else if(flag[0]) begin
	  aligned = 1;
          ostream = {s1, buf1};
        end
      end
    endcase
  endfunction
  
  // Function to determine the next state and computation of logical buffers.
  function automatic void ref_next(
     input  logic [2:0] state,        
     input  logic [3:0] s1, s2,
     input  logic [1:0] flag,
     input  logic [3:0] buf0, buf1,
     output logic [2:0] nstate
  );
    
    case(state)
      IDLE: begin
	flag = 2'd0;
	buf0 = 4'd0;
	buf1 = 4'd0;
	if(s1 == 4'hA && s2 == 4'hA)  nstate = BOTH;
	else if(s1 == 4'hA)           nstate = AFIRST;
	else if(s2 == 4'hA)           nstate = BFIRST;
	else                          nstate = IDLE;
      end
      BOTH: nstate = BOTH;
      AFIRST: begin
	flag[0] = (flag[0]) ? flag[0] : (s2 == 4'hA) ? 1 : 0;
	if(s2 == 4'hA && !flag[0]) begin
	  buf1 = buf0;
	  buf0 = s1;
        end else if(flag[0]) begin
	  buf1 = buf0;
	  buf0 = s1;
        end else begin
	  buf0 = s1;
        end
	nstate = (s2 == 4'hA || flag[0]) ? AFIRST : A1FIRST;
      end
      BFIRST: begin
	flag[0] = (flag[0]) ? flag[0] : (s1 == 4'hA) ? 1 : 0;
	if(s1 == 4'hA && !flag[0]) begin
	  buf1 = buf0;
	  buf0 = s2;
        end else if(flag[0]) begin
	  buf1 = buf0;
	  buf0 = s2;
        end else begin
	  buf0 = s2;
        end
	nstate = (s1 == 4'hA || flag[0]) ? BFIRST : B1FIRST;
      end
      A1FIRST: begin
	flag[1] = (flag[1]) ? flag[1] : (s2 == 4'hA) ? 1 : 0;
	if(s2 == 4'hA && !flag[1]) begin
	  buf1 = buf0;
	  buf0 = s1;
        end else if(flag[1]) begin
	  buf1 = buf0;
	  buf0 = s1;
        end else begin
	  buf0 = s1;
        end
	nstate = (s2 == 4'hA || flag[1]) ? A1FIRST : IDLE;
      end
      B1FIRST: begin
	flag[1] = (flag[1]) ? flag[1] : (s1 == 4'hA) ? 1 : 0;
	if(s1 == 4'hA && !flag[1]) begin
	  buf1 = buf0;
	  buf0 = s2;
        end else if(flag[1]) begin
	  buf1 = buf0;
	  buf0 = s2;
        end else begin
	  buf0 = s2;
        end
	nstate = (s1 == 4'hA || flag[1]) ? B1FIRST : IDLE;
      end
      default: nstate = IDLE;
    endcase
  endfunction

  // Task to compute the next state and current state outputs
  task step_model(input logic [3:0] s1, s2, input logic rst);
    logic [2:0] nstate;
    
    if(rst) begin
      ref_state = IDLE;
      ref_flag  = 2'd0;
      ref_buff[0] = 4'd0;
      ref_buff[1] = 4'd0;
      exp_ostream = 8'd0;
      exp_aligned = 0;
      return;
    end

    ref_output(ref_state, s1, s2, ref_flag,
	       ref_buff[0], ref_buff[1],
	       exp_ostream, exp_aligned);

    ref_next(ref_state, s1, s2, ref_flag,
	     ref_buff[0], ref_buff[1], nstate);
    ref_state = nstate;
  endtask
  
  // Main task that computes the expected outputs and compare them with the
  // actual outputs
  task run();
    transaction rx;

    logic [7:0] prev_exp_ostream = 8'h00;
    logic       prev_exp_aligned = 0;
    logic       first_cycle      = 1;

    repeat(num_cases) begin
      mon2scb.get(rx);
      step_model(rx.i_stream1, rx.i_stream2, rx.i_reset);

      if(first_cycle) begin
	prev_exp_ostream = exp_ostream;
	prev_exp_aligned = exp_aligned;
	first_cycle = 0;
	continue;
      end

      if((rx.o_stream == prev_exp_ostream) && (rx.o_aligned) == prev_exp_aligned) begin
	$display("[SCB] PASS | s1 = %0h | s2 = %0h | o_stream = %02h (exp:%02h) | o_aligned %0b (exp:%0b)",
		 rx.i_stream1, rx.i_stream2, rx.o_stream, prev_exp_ostream, rx.o_aligned, prev_exp_aligned 
		);
	pass_count++;
      end else begin
	$display("[SCB] FAIL | s1 = %0h | s2 = %0h | o_stream = %02h (exp:%02h) | o_aligned %0b (exp:%0b)",
		 rx.i_stream1, rx.i_stream2, rx.o_stream, prev_exp_ostream, rx.o_aligned, prev_exp_aligned 
		);
	fail_count++;     
      end
      prev_exp_ostream = exp_ostream;
      prev_exp_aligned = exp_aligned;
    end

    $display("[SCB] RESULTS PASSED = %0d | FAILED = %0d | TOTAL = %0d", pass_count, fail_count, num_cases);
  endtask
endclass
