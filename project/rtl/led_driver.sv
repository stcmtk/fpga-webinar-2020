module led_driver #(
  parameter SYMBOL_W = 8,
  parameter LEDS_CNT = 8
)(
  input  logic                clk_i,
  input  logic                s_rst_i,

  input  logic [SYMBOL_W-1:0] current_symbol_i,
  input  logic                user_in_game_i,

  // 1 -- user win, 0 -- user lost.
  // valid only when user_in_game_o is 0.
  input  logic                user_win_nlost_i,
  output logic [LEDS_CNT-1:0] leds_o
);

localparam WIN_LOOSE_PAUSE   = 6250000;
localparam WIN_LOOSE_PAUSE_W = $clog2(WIN_LOOSE_PAUSE);

logic [LEDS_CNT-1:0]          leds;
logic [WIN_LOOSE_PAUSE_W-1:0] win_cnt_period;
logic [WIN_LOOSE_PAUSE_W-1:0] loose_cnt_period;

logic [LEDS_CNT-1:0] win_cnt;
logic [LEDS_CNT-1:0] loose_cnt;


always_ff @( posedge clk_i )
  begin
    if( s_rst_i )
      begin
        win_cnt_period   <= '0;
        loose_cnt_period <= '0;
      end
    else
      if( win_cnt_period == ( WIN_LOOSE_PAUSE - 1 ) )
        begin
          win_cnt_period   <= '0;
          loose_cnt_period <= '0;
        end
      else
        begin
          win_cnt_period   <= win_cnt_period   + (WIN_LOOSE_PAUSE_W)'(1);
          loose_cnt_period <= loose_cnt_period + (WIN_LOOSE_PAUSE_W)'(1);
        end
  end

always_ff @( posedge clk_i )
  begin
    if( s_rst_i )
      win_cnt <= (LEDS_CNT)'(1);
    if( win_cnt_period == ( WIN_LOOSE_PAUSE - 1 ) )
      begin
        if( win_cnt[LEDS_CNT-1] )
          begin
            win_cnt[0]            <= 1'b1;
            win_cnt[LEDS_CNT-1:1] <= '0;
          end
        else
          begin
            win_cnt[0] <= 1'b0;
            win_cnt[LEDS_CNT-1:1] <= win_cnt[LEDS_CNT-2:0];
          end
      end
  end

always_ff @( posedge clk_i )
  begin
    if( s_rst_i )
      loose_cnt <= '1;
    if( win_cnt_period == ( WIN_LOOSE_PAUSE - 1 ) )
      begin
        // Inverse all bits:
        loose_cnt <= ~loose_cnt;
      end
  end

always_comb
  case( { user_in_game_i, user_win_nlost_i } )
    2'b11,
    2'b10:
      begin
        leds = current_symbol_i;
      end

    2'b01:
      begin
        leds = win_cnt;
      end

    2'b00:
      begin
        leds = loose_cnt;
      end

    default:

      begin
        leds = '0;
      end
  endcase

// Register leds to remove glitches:
always_ff @( posedge clk_i )
  if( s_rst_i )
    leds_o <= '0;
  else
    leds_o <= leds;

endmodule

