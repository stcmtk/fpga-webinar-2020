module fsm_top(
  input  logic       clk_i,
  input  logic       s_rst_i,

  input  logic       next_state_stb_i,
  output logic [1:0] value_o
);

logic       s_rst;
logic       next_state_stb;
logic [1:0] value;

always_ff @( posedge clk_i )
  begin
    s_rst          <= s_rst_i;
    next_state_stb <= next_state_stb_i;
  end

fsm fsm_ins(
  .clk_i            ( clk_i          ),
  .s_rst_i          ( s_rst          ),

  .next_state_stb_i ( next_state_stb ),
  .value_o          ( value          )
);

always_ff @( posedge clk_i )
  value_o <= value;

endmodule
