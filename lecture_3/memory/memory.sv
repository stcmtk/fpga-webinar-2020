module memory #(
  parameter ADDR_W = 5,
  parameter DATA_W = 10
)(
  input logic               clk_i,
  input logic [DATA_W-1:0]  d_i,
  input logic [ADDR_W-1:0]  write_address_i,
  input logic [ADDR_W-1:0]  read_address_i,
  input logic               we_i,

  output logic [DATA_W-1:0] q_o
);

logic [DATA_W-1:0] mem [2**ADDR_W-1:0];

always_ff @( posedge clk_i )
  begin

    if( we_i )
      mem[write_address_i] <= d_i;

    q_o <= mem[read_address_i];
 end

endmodule
