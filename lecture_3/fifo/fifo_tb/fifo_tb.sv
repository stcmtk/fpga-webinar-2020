module fifo_tb;

parameter DATA_W = 30;
parameter ADDR_W = 5;
parameter TEST_CNT = 100;

bit   clk;
bit   rst;
bit   rst_done;

logic               wr_req;
logic [DATA_W-1:0]  wr_data;
logic               full;

logic               rd_req;
logic [DATA_W-1:0]  rd_data;
logic               empty;

initial
  forever
    #5 clk = !clk;

default clocking cb
  @ (posedge clk);
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

fifo #(
  .DATA_W    ( DATA_W  ),
  .ADDR_W    ( ADDR_W  )
) fifo_ins (
  .clk_i     ( clk     ),
  .s_rst_i   ( rst     ),

  .wr_req_i  ( wr_req  ),
  .wr_data_i ( wr_data ),
  .full_o    ( full    ),

  .rd_req_i  ( rd_req  ),
  .rd_data_o ( rd_data ),
  .empty_o   ( empty   )
);

int                             cnt;
mailbox #( logic [DATA_W-1:0] ) generated_data = new();
mailbox #( logic [DATA_W-1:0] ) sended_data    = new();
mailbox #( logic [DATA_W-1:0] ) read_data      = new();

task gen_data(  input  int                      cnt,
                mailbox #( logic [DATA_W-1:0] ) data );

logic [DATA_W-1:0] data_to_send;

  for( int i = 0; i < cnt; i++ )
    begin
      data_to_send = $urandom_range(2**DATA_W-1,0);
      data.put( data_to_send );
    end

endtask

task fifo_wr( mailbox #( logic [DATA_W-1:0] ) data,
              mailbox #( logic [DATA_W-1:0] ) sended_data,
              input  bit                      burst = 0
            );

  logic [DATA_W-1:0] word_to_wr;
  int                pause;
  while( data.num() )
    begin
      data.get(word_to_wr);
      if( burst )
        pause = 0;
      else
        pause = $urandom_range(10,0);

      wr_data <= word_to_wr;
      wr_req  <= 1'b1;
      ##1;

      if( !full )
        sended_data.put( word_to_wr );

      if( pause != 0 )
        begin
          wr_req  <= 1'b0;
          ##pause;
        end
    end
  wr_req <= 1'b0;
endtask

task fifo_rd( mailbox #( logic [DATA_W-1:0] ) read_data,
              input  int                      empty_timeout,
              input  bit                      burst = 0
            );

  int no_empty_counter;
  int pause;

  forever
    begin
      if( !empty )
        begin
          if( burst )
            pause = 0;
          else
            pause = $urandom_range(10,0);

          no_empty_counter  = 0;

          rd_req           <= 1'b1;
          ##1;
          read_data.put( rd_data );
          if( pause != 0 )
            begin
              rd_req <= 0;
              ##pause;
            end
        end
      else
        begin

          if( no_empty_counter == empty_timeout )
            return;
          else
            no_empty_counter += 1;

          ##1;
        end
    end
endtask

task compare_data( mailbox #( logic [DATA_W-1:0] ) ref_data,
                   mailbox #( logic [DATA_W-1:0] ) dut_data
                 );

logic [DATA_W-1:0] ref_data_tmp;
logic [DATA_W-1:0] dut_data_tmp;

  if( ref_data.num() != dut_data.num() )
    begin
      $display( "Size of ref data: %d", ref_data.num() );
      $display( "And sized of dut data: %d", dut_data.num() );
      $display( "Do not match" );
      $stop();
    end
  else
    begin
      for( int i = 0; i < dut_data.num(); i++ )
        begin
          dut_data.get( dut_data_tmp );
          ref_data.get( ref_data_tmp );
          if( ref_data_tmp != dut_data_tmp )
            begin
              $display( "Error! Data do not match!" );
              $display( "Reference data: %x", ref_data_tmp );
              $display( "Read data: %x", dut_data_tmp );
              $stop();
            end
        end
    end

endtask

initial
  begin
    wr_data <= '0;
    wr_req  <= 1'b0;
    rd_req  <= 1'b0;

    gen_data( TEST_CNT, generated_data );

    wait( rst_done );

    fork
      fifo_wr(generated_data, sended_data);
      fifo_rd(read_data, 1000);
    join

    compare_data(sended_data, read_data);
    $display( "Test done! No errors!" );
    $stop();
  end


endmodule
