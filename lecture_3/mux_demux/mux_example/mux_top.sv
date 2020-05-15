module mux_top(
  input  logic       clk_i,

  input  logic       sel_i,

  input  logic [7:0] data_0_i,
  input  logic [7:0] data_1_i,
  output logic [7:0] data_out_o
);

logic [1:0][7:0] data_in;
logic            sel_in;
logic [7:0]      data_out;

always_ff @( posedge clk_i )
  begin
    data_in[0] <= data_0_i;
    data_in[1] <= data_1_i;
  end

always_ff @( posedge clk_i )
  sel_in <= sel_i;

mux #(
  .IN_CNT      ( 2          ),
  .DATA_W      ( 8          )
) mux_ins (
  .data_i      ( data_in    ),
  .sel_i       ( sel_in     ),
  .muxed_out_o ( data_out   )
);

always_ff @( posedge clk_i )
  data_out_o <= data_out;

endmodule
