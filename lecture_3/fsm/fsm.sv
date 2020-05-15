module fsm(
  input  logic       clk_i,
  input  logic       s_rst_i,

  input  logic       next_state_stb_i,
  output logic [1:0] value_o
);

enum logic [1:0] {
  IDLE_S,
  STATE_1,
  STATE_2
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
          if( next_state_stb_i )
            next_state = STATE_1;
        end
      STATE_1:
        begin
          if( next_state_stb_i )
            next_state = STATE_2;
        end
      STATE_2:
        begin
          if( next_state_stb_i )
            next_state = IDLE_S;
        end
    default:
      begin
        next_state = IDLE_S;
      end
    endcase
  end

always_comb
  begin
    value_o = '0;
    case( state )
      IDLE_S:
        begin
          value_o = 2'd0;
        end
      STATE_1:
        begin
          value_o = 2'd2;
        end
      STATE_2:
        begin
          value_o = 2'd1;
        end
    default:
      begin
          value_o = 2'd0;
      end
    endcase
  end

endmodule
