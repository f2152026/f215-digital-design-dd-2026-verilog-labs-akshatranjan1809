// tb.v

module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  integer i, j;
  integer errors;

  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i;
        t_b = j;
        #5;
        if (t_gt !== (t_a >  t_b) ||
            t_lt !== (t_a <  t_b) ||
            t_eq !== (t_a == t_b)) begin
          $display("MISMATCH: A=%d B=%d | GT=%b LT=%b EQ=%b",
                    t_a, t_b, t_gt, t_lt, t_eq);
          errors = errors + 1;
        end
      end
    end

    if (errors == 0)
      $display("All test cases passed.");
    else
      $display("%0d mismatch(es) found.", errors);

    $finish;
  end

  initial
    $monitor($time, " A=%d B=%d | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule