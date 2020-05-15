module fifo #(
  parameter DATA_W = 5,
  parameter ADDR_W = 4
)(
  input  logic              clk_i,
  input  logic              s_rst_i,

  input  logic              wr_req_i,
  input  logic [DATA_W-1:0] wr_data_i,
  output logic              full_o,

  input  logic              rd_req_i,
  output logic [DATA_W-1:0] rd_data_o,
  output logic              empty_o
);

localparam PTR_W = ADDR_W+1;

logic [PTR_W-1:0] rd_ptr;
logic [PTR_W-1:0] wr_ptr;

logic [DATA_W-1:0] mem [2**ADDR_W-1:0];

always_ff @( posedge clk_i or posedge s_rst_i )
  if( s_rst_i )
    begin
      rd_ptr <= '0;
      wr_ptr <= '0;
    end
  else
    begin
      if( rd_req_i && !empty_o )
        rd_ptr <= rd_ptr + (PTR_W)'(1);
      if( wr_req_i && !full_o )
        wr_ptr <= wr_ptr + (PTR_W)'(1);
    end

always_ff @( posedge clk_i )
  if( wr_req_i )
    mem[wr_ptr[ADDR_W-1:0]] <= wr_data_i;

always_ff @( posedge clk_i )
  if( rd_req_i )
    rd_data_o <= mem[rd_ptr[ADDR_W-1:0]];

assign empty_o = ( rd_ptr             == wr_ptr             );
assign full_o  = ( rd_ptr[ADDR_W-1:0] == wr_ptr[ADDR_W-1:0] ) &&
                 ( rd_ptr[PTR_W-1]    != wr_ptr[PTR_W-1]     );
endmodule
