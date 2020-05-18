module posedge_detector (
  input  clk_i,
  input  d_i,
  output posedge_stb_o
);

logic d_delay;

always_ff @( posedge clk_i )
  d_delay <= d_i;

assign posedge_stb_o = d_i && !d_delay;

endmodule
