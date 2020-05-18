module nback_top (
  input  logic       clk_50_mhz_i,
  input  logic       key_0_i,
  input  logic       key_1_i,
  output logic [7:0] leds_o
);

logic [1:0] pin_1_d;
logic       s_rst;
logic       user_answer;
logic       user_answer_stb;

logic      key_0_inv;
logic      key_1_inv;

assign key_0_inv = !key_0_i;
assign key_1_inv = !key_1_i;

always_ff @( posedge clk_50_mhz_i )
  begin
    pin_1_d[0] <= key_1_inv;
    pin_1_d[1] <= pin_1_d[0];
  end

assign s_rst = pin_1_d[1];

debouncer #(
  .DB_CNT_W      ( 10              )
) db_inst (
  .clk_i         ( clk_50_mhz_i    ),
  .s_rst_i       ( s_rst           ),

  .pin_i         ( key_0_inv       ),
  .pin_state_o   ( user_answer     )
);

posedge_detector pd_inst(
  .clk_i         ( clk_50_mhz_i    ),
  .d_i           ( user_answer     ),
  .posedge_stb_o ( user_answer_stb )
);

logic prbs_ack;
logic prbs;

logic [7:0] current_symbol;
logic       user_in_game;
logic       user_win_nlost;

nback_logic #(
  .N                        ( 3              ),
  .SYMBOL_W                 ( 8              ),
  .SYMBOL_DURATION_HW_TICKS ( 200000000      ), // 4 second: 4 / 20 ns
  .PAUSE_DURATINON_HW_TICKS ( 200000000      )  // 4 second
) nback_inst (
  .clk_i                    ( clk_50_mhz_i   ),
  .s_rst_i                  ( s_rst          ),

  .answer_stb_i             ( user_answer    ),

  .prbs_i                   ( prbs           ),
  .prbs_ack_o               ( prbs_ack       ),

  .current_symbol_o         ( current_symbol ),
  .user_in_game_o           ( user_in_game   ),

  .user_win_nlost_o         ( user_win_nlost )
);

lfsr_9bit prbs_inst(
 .clk_i   ( clk_50_mhz_i ),
 .s_rst_i ( s_rst        ),

 .ack_i   ( prbs_ack     ),
 .prbs_o  ( prbs         )
);

led_driver #(
  .SYMBOL_W         ( 8              ),
  .LEDS_CNT         ( 8              )
) leds_inst (
  .clk_i            ( clk_50_mhz_i   ),
  .s_rst_i          ( s_rst          ),

  .current_symbol_i ( current_symbol ),
  .user_in_game_i   ( user_in_game   ),

  .user_win_nlost_i ( user_win_nlost ),
  .leds_o           ( leds_o         )
);


endmodule
