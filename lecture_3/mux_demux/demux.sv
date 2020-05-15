module demux #(
  parameter OUT_CNT = 2,
  parameter DATA_W  = 7
)(
  input  logic [DATA_W-1:0]              data_i,
  input  logic [$clog2(OUT_CNT)-1:0]     sel_i,
  output logic [OUT_CNT-1:0][DATA_W-1:0] demuxed_out_o
);

always_comb
  begin
    demuxed_out_o = '0;
    demuxed_out_o[ sel_i ] = data_i;
  end

endmodule
