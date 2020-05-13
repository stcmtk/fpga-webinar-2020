module top_tb;
bit clk;
bit reset;
initial
  forever
    #5 clk = !clk;

logic [3:0] cnt_from_dut;

counter DUT (
  .clock_i ( clk          ),
  .reset_i ( reset        ),
  .data_o  ( cnt_from_dut )
);

initial
  begin
    reset <= 1'b0;
    #99;
    @( posedge clk );
    reset <= 1'b1;
    @( posedge clk );
    reset <= 1'b0;
    $display( cnt_from_dut );
    @( posedge clk );
    $display( cnt_from_dut );
  end
endmodule

