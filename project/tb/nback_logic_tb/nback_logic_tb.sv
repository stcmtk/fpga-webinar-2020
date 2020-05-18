module nback_logic_tb;

parameter N                        = 3;
parameter SYMBOL_W                 = 7;
parameter SYMBOL_DURATION_HW_TICKS = 3000;
parameter PAUSE_DURATINON_HW_TICKS = 500;

bit   clk;
bit   rst;
bit   rst_done;

logic                answer_stb;
logic                prbs_ack;
logic                prbs;
logic [SYMBOL_W-1:0] current_symbol;
logic                user_in_game;
logic                user_win_nlost;

initial
  forever
    #5 clk = !clk;

default clocking cb @ (posedge clk);
endclocking

initial
 begin
   rst <= 1'b0;
   ##1;
   rst <= 1'b1;
   ##1;
   rst <= 1'b0;
   rst_done = 1'b1;
 end

nback_logic #(
  .N                        ( N                        ),
  .SYMBOL_W                 ( SYMBOL_W                 ),
  .SYMBOL_DURATION_HW_TICKS ( SYMBOL_DURATION_HW_TICKS ),
  .PAUSE_DURATINON_HW_TICKS ( PAUSE_DURATINON_HW_TICKS )
) DUT (
  .clk_i                    ( clk                      ),
  .s_rst_i                  ( rst                      ),

  .answer_stb_i             ( answer_stb               ),

  .prbs_i                   ( prbs                     ),
  .prbs_ack_o               ( prbs_ack                 ),

  .current_symbol_o         ( current_symbol           ),
  .user_in_game_o           ( user_in_game             ),

  .user_win_nlost_o         ( user_win_nlost           )
);

initial
  begin
    prbs <= $urandom_range(1,0);
    forever
      begin
        ##1;
        if( prbs_ack )
          prbs <= $urandom_range(1,0);
      end
  end

initial
  begin
    answer_stb <= 1'b0;
    wait( rst_done );
    ##100;
    answer_stb <= 1'b1;
    ##1;
    answer_stb <= 1'b0;
  end

endmodule
