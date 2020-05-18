module lfsr_9bit(
  input  logic clk_i,
  input  logic s_rst_i,

  input  logic ack_i,

  output logic prbs_o
);

// Полином: x^9 + x^5 + 1
parameter WIDTH = 9;
parameter TAP1  = WIDTH-1;
parameter TAP2  = 4;

logic [WIDTH-1:0] prbs_state;

always_ff @( posedge clk_i )
  if( s_rst_i )
    prbs_state <= (WIDTH)'(1);
  else
    begin
      if( ack_i )
        begin
          prbs_state[0]         <= prbs_state[TAP1] ^ prbs_state[TAP2];
          prbs_state[WIDTH-1:1] <= prbs_state[WIDTH-2:0];
        end
    end

assign prbs_o = prbs_state[0];

endmodule
