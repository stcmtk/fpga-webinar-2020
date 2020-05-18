module prbs_tb;

bit   clk;
bit   rst;
bit   rst_done;

logic ack;
logic prbs;

initial
  forever
    #5 clk = !clk;

default clocking cb @ (posedge clk);
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

lfsr_9bit prbs_inst(
  .clk_i   ( clk  ),
  .s_rst_i ( rst  ),

  .ack_i   ( ack  ),

  .prbs_o  ( prbs )
);

bit prbs_seq     [$];
int ref_file_descr;
bit ref_prbs;
bit ref_prbs_seq [$];

initial
  begin
    ack <= 1'b0;
    wait( rst_done );
    repeat(1000)
      begin
        prbs_seq.push_back( prbs );
        ack <= 1'b1;
        ##1;
        ack <= 1'b0;
        ##1;
      end

    ref_file_descr = $fopen("ref_results.txt", "r");

    if( !ref_file_descr )
      begin
        $display("File ref_results.txt was NOT found!");
        $stop();
      end

    while( !$feof(ref_file_descr) )
      begin
        $fscanf(ref_file_descr, "%b", ref_prbs );
        ref_prbs_seq.push_back( ref_prbs );
      end

    if( ref_prbs_seq != prbs_seq )
      begin
        $error("Reference and DUR LSFR sequences do not match");
        for( int i = 0; i < prbs_seq.size(); i++ )
          if( ref_prbs_seq[i] != prbs_seq[i] )
            $display("Error in bit #", i );

        $display( "%d", ref_prbs_seq.size() );
        $display( "%d", prbs_seq.size()     );
      end

    $stop();
  end

endmodule
