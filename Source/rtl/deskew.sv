//////////////////////////////////////////////////////////////////////////////////////////////
// File Name        :  deskew.sv
// Description      :  deskew.sv is the design module that aligns (deskews) two incoming 4-bit
//                     data streams when the value 4'hA is detected on both inputs within a 
//                     maximum skew of two clock cycles. It uses a finite state machine (FSM),
//                     small buffers, and flags to track which stream detects A first and to
//                     delay the earlier stream as needed. Once both streams are aligned, the
//                     module outputs the concatenated 8-bit stream (o_stream) with the 
//                     first-detected stream placed in the LSBs and asserts o_aligned to 
//                     indicate successful alignment.
// Inputs           :  Clock, Reset (Active High), Stream 1 and Stream 2
// Outputs          :  Aligned Flag and Aligned Stream  
//////////////////////////////////////////////////////////////////////////////////////////////

module deskew (
    input       i_clk,      // Inputs
    input       i_reset,    // Synchrnous Reset
    input [3:0] i_stream1,
    input [3:0] i_stream2,

    output reg [7:0] o_stream,  // Outputs
    output reg       o_aligned
);
  localparam IDLE = 0,  // States of the FSM 
  BOTH = 1, AFIRST = 2, BFIRST = 3, A1FIRST = 4, B1FIRST = 5;

  // Internal Registers
  reg [2:0] state, next_state;
  reg [3:0] buffer[0:1];
  reg [1:0] flag;

  // State Transiton Logic
  always @(posedge i_clk) begin
    if (i_reset) state <= IDLE;
    else state <= next_state;
  end

  // Next State Calculation
  always @(*) begin
    case (state)
      IDLE:
      next_state = (i_stream1 == 4'ha && i_stream2 == 4'ha) ? BOTH : (i_stream1 == 4'ha) ? AFIRST : (i_stream2 == 4'ha) ? BFIRST : IDLE;
      BOTH: next_state = BOTH;
      AFIRST: next_state = (i_stream2 == 4'ha || flag[0] == 1'b1) ? AFIRST : A1FIRST;
      BFIRST: next_state = (i_stream1 == 4'ha || flag[0] == 1'b1) ? BFIRST : B1FIRST;
      A1FIRST: next_state = (i_stream2 == 4'ha || flag[1] == 1'b1) ? A1FIRST : IDLE;
      B1FIRST: next_state = (i_stream1 == 4'ha || flag[1] == 1'b1) ? B1FIRST : IDLE;
      default: next_state = IDLE;
    endcase
  end

  // Output Logic	
  always @(posedge i_clk) begin
    case (state)
      IDLE: begin
        o_aligned <= 1'b0;
        o_stream  <= {8{1'b0}};
        flag      <= 2'd0;
        buffer[1] <= 4'd0;
        buffer[0] <= 4'd0;
        if (i_stream1 == 4'ha && i_stream2 == 4'ha) begin
          o_stream  <= {i_stream1, i_stream2};
          o_aligned <= 1'b1;
        end
      end
      BOTH: begin
        o_aligned <= 1'b1;
        o_stream  <= {i_stream2, i_stream1};
      end
      AFIRST: begin
        flag[0] <= (flag[0] == 1'b1) ? flag[0] : (i_stream2 == 4'ha) ? 1'b1 : 1'b0;
        if (i_stream2 == 4'ha && flag[0] == 1'b0) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream2, 4'ha};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream1;
        end else if (flag[0]) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream2, buffer[0]};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream1;
        end else begin
          buffer[0] <= i_stream1;
        end
      end
      BFIRST: begin
        flag[0] <= (flag[0] == 1'b1) ? flag[0] : (i_stream1 == 4'ha) ? 1'b1 : 1'b0;
        if (i_stream1 == 4'ha && flag[0] == 1'b0) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream1, 4'ha};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream2;
        end else if (flag[0]) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream1, buffer[0]};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream2;
        end else begin
          buffer[0] <= i_stream2;
        end
      end
      A1FIRST: begin
        flag[1] <= (flag[1] == 1'b1) ? flag[1] : (i_stream2 == 4'ha) ? 1'b1 : 1'b0;
        if (i_stream2 == 4'ha && flag[1] == 1'b0) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream2, 4'ha};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream1;
        end else if (flag[1]) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream2, buffer[1]};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream1;
        end else begin
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream1;
        end
      end
      B1FIRST: begin
        flag[1] <= (flag[1] == 1'b1) ? flag[1] : (i_stream1 == 4'ha) ? 1'b1 : 1'b0;
        if (i_stream1 == 4'ha && flag[1] == 1'b0) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream1, 4'ha};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream2;
        end else if (flag[1]) begin
          o_aligned <= 1'b1;
          o_stream  <= {i_stream1, buffer[1]};
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream2;
        end else begin
          buffer[1] <= buffer[0];
          buffer[0] <= i_stream2;
        end
      end
      default: begin
        o_aligned <= 1'b0;
        o_stream  <= {8{1'b0}};
        flag      <= 2'd0;
        buffer[1] <= 4'd0;
        buffer[0] <= 4'd0;
      end
    endcase
  end
endmodule
