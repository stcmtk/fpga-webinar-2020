module counter (
  input         clock_i,
  input         reset_i,
  output [3:0]  data_o
);

  logic  [3:0] cnt;

  always_ff @( posedge clock_i )
    begin
      if( reset_i )
        cnt <= '0;
      else
        cnt <= cnt + 1;
    end

  assign  data_o = cnt;

endmodule
