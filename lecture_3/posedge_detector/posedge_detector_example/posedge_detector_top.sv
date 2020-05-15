module posedge_detector_top(
  input  logic clk_i,

  input  logic d_i,
  output logic d_o
);

logic data_in;
logic data_out;

always_ff @( posedge clk_i )
  data_in <= d_i;

posedge_detector pd_ins (
  .clk_i         ( clk_i    ),
  .d_i           ( data_in  ),
  .posedge_stb_o ( data_out )
);

always_ff @( posedge clk_i )
  d_o <= data_out;

endmodule
