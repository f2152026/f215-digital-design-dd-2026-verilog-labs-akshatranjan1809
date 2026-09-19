// tb.v

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  integer errors;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check;
    reg [3:0] expected;
    begin
      expected = t_op ? (t_a - t_b) : (t_a + t_b);
      if (t_result !== expected) begin
        $display("MISMATCH: a=%d b=%d op=%b | result=%d expected=%d",
                  t_a, t_b, t_op, t_result, expected);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;

    // Basic add
    t_a = 4'd5; t_b = 4'd3; t_op = 0; #5 check;

    // Basic sub
    t_a = 4'd5; t_b = 4'd3; t_op = 1; #5 check;

    // Hold a, b steady and toggle op -- exposes the sensitivity-list bug,
    // since the always block only lists a and b, not op.
    t_a = 4'd7; t_b = 4'd2;
    t_op = 0; #5 check;
    t_op = 1; #5 check;
    t_op = 0; #5 check;

    // Change b only, with op already 1 -- exposes the blocking/non-blocking
    // bug, since b_inv/b_twos/result are chained with <= inside the same
    // always block and will use stale values on the first pass.
    t_a = 4'd9; t_b = 4'd4; t_op = 1; #5 check;
    t_b = 4'd1;             #5 check;

    if (errors == 0)
      $display("All test cases passed.");
    else
      $display("%0d mismatch(es) found.", errors);

    $finish;
  end

  initial
    $monitor($time, " a=%d b=%d op=%b | result=%d", t_a, t_b, t_op, t_result);

endmodule