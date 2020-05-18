module nback_logic #(
  parameter N                        = 3,
  parameter SYMBOL_W                 = 7,
  parameter SYMBOL_DURATION_HW_TICKS = 3000,
  parameter PAUSE_DURATINON_HW_TICKS = 500
)(
  input  logic                clk_i,
  input  logic                s_rst_i,

  input  logic                answer_stb_i,

  input  logic                prbs_i,
  output logic                prbs_ack_o,

  output logic [SYMBOL_W-1:0] current_symbol_o,
  output logic                user_in_game_o,

  // 1 -- user win, 0 -- user lost.
  // Valid only when user_in_game_o is 0.
  output logic                user_win_nlost_o
);

//// Local parameters calculation: ////
localparam PAUSE_CNT_W  = $clog2(PAUSE_DURATINON_HW_TICKS);
localparam SYMBOL_CNT_W = $clog2( SYMBOL_W );
localparam SYMBOL_DUR_W = $clog2(SYMBOL_DURATION_HW_TICKS);

//// Signals and registers: ////
logic [PAUSE_CNT_W-1:0]   pause_cnt;
logic                     pause_done;

logic [SYMBOL_W-1:0]      collected_symbol;

logic [SYMBOL_CNT_W-1:0]  symbol_cnt;
logic                     symbol_collected;

logic [SYMBOL_W-1:0]      next_symbol;

logic [N:0][SYMBOL_W-1:0] symbols_queue;
logic [$clog2(N):0]       symbols_queue_size;

logic [SYMBOL_DUR_W-1:0]  symbol_pause_cnt;
logic                     symbol_pause_done;

//// Main game FSM: ////
enum logic [2:0] {
  IDLE_S,
  PAUSE_S,
  COLLECT_PRBS_S,
  REPLACE_SYMBOL_S,
  SHIFT_SYMBOL_QUEUE_S,
  SHOW_SYNBOL_S,
  WIN_S,
  LOOSE_S
} state, next_state;

always_ff @( posedge clk_i )
  if( s_rst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( answer_stb_i )
            next_state = PAUSE_S;
        end
      PAUSE_S:
        begin
          if( pause_done )
            next_state = COLLECT_PRBS_S;
        end

      COLLECT_PRBS_S:
        begin
          if( symbol_collected )
            next_state = REPLACE_SYMBOL_S;
        end

      REPLACE_SYMBOL_S:
        begin
          next_state = SHIFT_SYMBOL_QUEUE_S;
        end

      SHIFT_SYMBOL_QUEUE_S:
        begin
          next_state = SHOW_SYNBOL_S;
        end

      SHOW_SYNBOL_S:
        begin
          if( answer_stb_i )
            begin
              if( ( symbols_queue[0] == symbols_queue[N] ) &&
                  ( symbols_queue_size == N              ) )
                next_state = WIN_S;
              else
                next_state = LOOSE_S;
            end
          if( symbol_pause_done )
            begin
              if( ( symbols_queue[0] == symbols_queue[N] ) &&
                  ( symbols_queue_size == N              ) )
                next_state = LOOSE_S;
              else
                next_state = PAUSE_S;
            end
        end

      WIN_S,
      LOOSE_S:
        begin
          if( symbol_pause_done )
            next_state = IDLE_S;
        end

      default:
        begin
          next_state = IDLE_S;
        end
    endcase
  end

// Counter for counting how log pause shuld be:
always_ff @( posedge clk_i )
  if( state == PAUSE_S )
    pause_cnt <= pause_cnt + (PAUSE_CNT_W)'(1);
  else
    pause_cnt <= '0;

assign pause_done = ( pause_cnt == ( PAUSE_DURATINON_HW_TICKS - 1 ) );

// PRBS collection process:
always_ff @( posedge clk_i )
  if( state == COLLECT_PRBS_S )
    begin
      collected_symbol[0]            <= prbs_i;
      collected_symbol[SYMBOL_W-1:1] <= collected_symbol[SYMBOL_W-2:0];
    end

assign prbs_ack_o = (state == COLLECT_PRBS_S);

always_ff @( posedge clk_i )
  if( state == COLLECT_PRBS_S )
    symbol_cnt <= symbol_cnt + (SYMBOL_CNT_W)'(1);
  else
    symbol_cnt <= '0;

assign symbol_collected = ( symbol_cnt == ( SYMBOL_W - 1 ) );

// Replace PRBS symbol for win one, if there is enought symbols and the last 2
// bits of new symbol is 00 (this will make it 25% chance).

always_ff @( posedge clk_i )
  if( state == REPLACE_SYMBOL_S )
    begin
      if( ( symbols_queue_size == N ) && ( collected_symbol[1:0] == 2'b00 ) )
        next_symbol <= symbols_queue[N-1];
      else
        next_symbol <= collected_symbol;
    end

// Saving symbols to queue:
always_ff @( posedge clk_i )
  if( s_rst_i )
    symbols_queue_size <= '0;
  else
    if( state == IDLE_S )
      symbols_queue_size <= '0;
    else
      if( state == SHIFT_SYMBOL_QUEUE_S )
        if( symbols_queue_size != N )
          symbols_queue_size <= symbols_queue_size + ($clog2(N))'(1);

always_ff @( posedge clk_i )
  if( state == SHIFT_SYMBOL_QUEUE_S )
    begin
      symbols_queue[0]   <= next_symbol;
      symbols_queue[N:1] <= symbols_queue[N-1:0];
    end

// Counting pause for symbol:
always_ff @( posedge clk_i )
  if( state != next_state )
    symbol_pause_cnt <= '0;
  else
    begin
      if( ( state == SHOW_SYNBOL_S ) ||
          ( state == WIN_S         ) ||
          ( state == LOOSE_S       ) )
          symbol_pause_cnt <= symbol_pause_cnt + (SYMBOL_DUR_W)'(1);
    end

assign symbol_pause_done = ( symbol_pause_cnt == SYMBOL_DURATION_HW_TICKS - 1 );

// Output signals logic:
always_comb
  begin
    current_symbol_o = '0;
    user_in_game_o   = 1'b0;
    user_win_nlost_o = 1'b0;

    case( state )
      IDLE_S:
        begin
          user_in_game_o   = 1'b0;
          user_win_nlost_o = 1'b0;
         end
      PAUSE_S,
      COLLECT_PRBS_S,
      REPLACE_SYMBOL_S,
      SHIFT_SYMBOL_QUEUE_S:
        begin
          user_in_game_o   = 1'b1;
          current_symbol_o = '0;
        end

      SHOW_SYNBOL_S:
        begin
          user_in_game_o   = 1'b1;
          current_symbol_o = symbols_queue[0];
        end

      WIN_S:
        begin
          user_in_game_o   = 1'b0;
          user_win_nlost_o = 1'b1;
        end

      LOOSE_S:
        begin
          user_in_game_o   = 1'b0;
          user_win_nlost_o = 1'b0;
        end

      default:
        begin
          current_symbol_o = '0;
          user_in_game_o   = 1'b0;
          user_win_nlost_o = 1'b0;
        end
    endcase
  end
endmodule
