module fifo_top(
  input  logic       clk_i,
  input  logic       s_rst_i,

  input  logic       wr_req_i,
  input  logic [7:0] wr_data_i,
  output logic       full_o,

  input  logic       rd_req_i,
  output logic [7:0] rd_data_o,
  output logic       empty_o
);

logic       s_rst;
logic       wr_req;
logic [7:0] wr_data;
logic       rd_req;

logic       full;
logic [7:0] rd_data;
logic       empty;

always_ff @( posedge clk_i )
  begin
    s_rst   <= s_rst_i;
    wr_req  <= wr_req_i;
    wr_data <= wr_data_i;
    rd_req  <= rd_req_i;
  end

fifo #(
  .ADDR_W          ( 4             ),
  .DATA_W          ( 8             )
) fifo_ins (
  .clk_i           ( clk_i         ),
  .s_rst_i         ( s_rst         ),

  .wr_req_i        ( wr_req        ),
  .wr_data_i       ( wr_data       ),
  .full_o          ( full          ),

  .rd_req_i        ( rd_req        ),
  .rd_data_o       ( rd_data       ),
  .empty_o         ( empty         )
);

always_ff @( posedge clk_i )
  begin
    full_o    <= full;
    rd_data_o <= rd_data;
    empty_o   <= empty;
  end

endmodule
