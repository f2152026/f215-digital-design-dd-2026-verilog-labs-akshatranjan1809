// and_beh_intra.v

module and_beh_intra (
  input      a,
  input      b,
  output reg y
);

  always @(a or b)
    y = #5 (a & b);

endmodule