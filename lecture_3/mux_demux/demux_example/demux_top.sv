module demux_top(
  input  logic       clk_i,

  input  logic       sel_i,

  input  logic [7:0] data_in_i,
  output logic [7:0] data_0_o,
  output logic [7:0] data_1_o
);

logic [7:0]      data_in;
logic            sel_in;
logic [1:0][7:0] data_out;

always_ff @( posedge clk_i )
  begin
    data_in <= data_in_i;
    sel_in  <= sel_i;
  end

demux #(
  .OUT_CNT       ( 2          ),
  .DATA_W        ( 8          )
) mux_ins (
  .data_i        ( data_in    ),
  .sel_i         ( sel_in     ),
  .demuxed_out_o ( data_out   )
);

always_ff @( posedge clk_i )
  begin
    data_0_o <= data_out[0];
    data_1_o <= data_out[1];
  end

endmodule
