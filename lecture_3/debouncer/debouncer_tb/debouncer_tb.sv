module debouncer_tb;

parameter PULSE_LENGTH = 10000;
parameter TASKS_CNT    = 100;

parameter CLEAR_TASK_CNT = TASKS_CNT/2;
parameter NOISE_TASK_CNT = TASKS_CNT - CLEAR_TASK_CNT;

bit   clk;
bit   rst;
bit   rst_done;

logic pin;
logic pin_state;

typedef struct {
  int before_stable_duration;
  int stable_duration;
  int after_stable_duration;
  int pause_duration;
} task_t;

typedef struct {
  int cnt;
  int max_duration;
  int min_duration;
  int total_duration;
} pulse_stat_t;

task generate_tasks ( mailbox #( task_t ) gt,
                      int                 task_cnt,
                      int                 stable_duration,
                      bit                 clear_signal = 0
                    );
  for (int i = 0; i < task_cnt; i++ )
    begin
      task_t new_task;
      if( clear_signal )
        begin
          new_task.before_stable_duration = 0;
          new_task.after_stable_duration  = 0;
        end
      else
        begin
          new_task.before_stable_duration = $urandom_range(stable_duration/4,1);
          new_task.after_stable_duration  = $urandom_range(stable_duration/4,1);
        end
      new_task.stable_duration = stable_duration;
      new_task.pause_duration  = stable_duration;
      gt.put( new_task );
    end
endtask

task recieve_tasks( int timeout, output pulse_stat_t signal_stat );
  automatic int tick_counter = 0;
  automatic int duration     = 0;

  signal_stat.cnt            = 0;
  signal_stat.total_duration = 0;
  signal_stat.max_duration   = 0;
  signal_stat.min_duration   = 2**31 - 1;

  while( tick_counter < timeout )
    begin
      while ( pin_state == 1'b0 )
        begin
          tick_counter += 1;
          ##1;
          if( tick_counter > timeout )
            return;
        end

      duration = 0;

      while ( pin_state )
        begin
          duration += 1;
          tick_counter += 1;
          ##1;
          if( tick_counter > timeout )
            return;
        end

      signal_stat.cnt            += 1;
      signal_stat.total_duration += duration;

      if( duration > signal_stat.max_duration )
        signal_stat.max_duration = duration;

      if( duration < signal_stat.min_duration )
        signal_stat.min_duration = duration;
    end

endtask

task send_tasks( mailbox #( task_t ) st );
  while ( st.num != 0 )
    begin
      task_t send_task;

      st.get( send_task );
      for ( int i = 0; i < send_task.before_stable_duration; i++ )
        begin
          ##1;
          pin <= $urandom_range(1,0);
        end

      for ( int i = 0; i < send_task.stable_duration; i++ )
        begin
          ##1;
          pin <= 1'b1;
        end

      for ( int i = 0; i < send_task.after_stable_duration; i++ )
        begin
          ##1;
          pin <= $urandom_range(1,0);
        end

      for ( int i = 0; i < send_task.pause_duration; i++ )
        begin
          ##1;
          pin <= 1'b0;
        end
    end
endtask

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

debouncer #(
  .DB_CNT_W    ( 10        )
) db_inst (
  .clk_i       ( clk       ),
  .s_rst_i     ( rst       ),

  .pin_i       ( pin       ),
  .pin_state_o ( pin_state )
);

mailbox #( task_t ) gen_tasks = new();
pulse_stat_t        clear_signal_stat;
pulse_stat_t        noise_signal_stat;

initial
  begin
    wait( rst_done );
    $display( "Starint tests. Config:");
    $display( "\t PULSE_LENGTH (stable time for each input pulse) = %d",
                  PULSE_LENGTH);

    $display( "\t TASKS_CNT (count of task to send) = %d",
                  TASKS_CNT);

    $display( "Starting with sending %d clear signals with no noise" ,
               CLEAR_TASK_CNT);

    generate_tasks( gen_tasks, CLEAR_TASK_CNT, PULSE_LENGTH, 1 );

    fork
      send_tasks( gen_tasks );
      recieve_tasks( PULSE_LENGTH * CLEAR_TASK_CNT * 2, clear_signal_stat );
    join

    if( clear_signal_stat.cnt != CLEAR_TASK_CNT )
      $error( "Not all pulses were recieved in clear test!" );

    $display( "### Test 1 with clear signal done ###" );
    $display( "\t Send pulses: %d" , CLEAR_TASK_CNT );
    $display( "\t Recieved pulses: %d", clear_signal_stat.cnt );
    $display( "\t Max pulse duration: %d", clear_signal_stat.max_duration );
    $display( "\t Min pulse duration: %d", clear_signal_stat.min_duration );
    $display( "\t Average pulse duration: %f", clear_signal_stat.total_duration / clear_signal_stat.cnt);

    $display( "Starting test #2: sending %d signals with noise" ,
               NOISE_TASK_CNT);

    generate_tasks( gen_tasks, NOISE_TASK_CNT, PULSE_LENGTH, 0 );

    fork
      send_tasks( gen_tasks );
      recieve_tasks( PULSE_LENGTH * NOISE_TASK_CNT * 2, noise_signal_stat );
    join

    if( noise_signal_stat.cnt != NOISE_TASK_CNT )
      $error( "Not all pulses were recieved in clear test!" );

    $display( "### Test 2 with clear signal done ###" );
    $display( "\t Send pulses: %d" , NOISE_TASK_CNT );
    $display( "\t Recieved pulses: %d", clear_signal_stat.cnt );
    $display( "\t Max pulse duration: %d", clear_signal_stat.max_duration );
    $display( "\t Min pulse duration: %d", clear_signal_stat.min_duration );
    $display( "\t Average pulse duration: %f", clear_signal_stat.total_duration / clear_signal_stat.cnt);

    $stop();
  end

endmodule
