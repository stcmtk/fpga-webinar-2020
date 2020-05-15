module memory_top(
  input logic        clk_i,
  input logic [9:0]  d_i,
  input logic [4:0]  write_address_i,
  input logic [4:0]  read_address_i,
  input logic        we_i,

  output logic [9:0] q_o
);

logic [9:0]  d;
logic [4:0]  write_address;
logic [4:0]  read_address;
logic        we;

logic [9:0]  q;

always_ff @( posedge clk_i )
  begin
    d             <= d_i;
    write_address <= write_address_i;
    read_address  <= read_address_i;
    we            <= we_i;
  end

memory #(
  .ADDR_W          ( 5             ),
  .DATA_W          ( 10            )
) mem_ins (
  .clk_i           ( clk_i         ),
  .d_i             ( d             ),
  .write_address_i ( write_address ),
  .read_address_i  ( read_address  ),
  .we_i            ( we            ),

  .q_o             ( q             )
);

always_ff @( posedge clk_i )
  q_o <= q;

endmodule
