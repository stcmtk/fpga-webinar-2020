module mux #(
  parameter IN_CNT = 2,
  parameter DATA_W = 7
)(
  input  logic [IN_CNT-1:0][DATA_W-1:0] data_i,
  input  logic [$clog2(IN_CNT)-1:0]     sel_i,
  output logic [DATA_W-1:0]             muxed_out_o
);

assign muxed_out_o = data_i[ sel_i ];

endmodule
