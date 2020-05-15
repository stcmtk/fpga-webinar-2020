module debouncer #(
  // Счетчик, который будет считать время, которое сигнал вел себя стабильно
  // Если это время достигнет 2**DB_CNT_W - 1 -- им можно пользоваться.
  parameter DB_CNT_W = 20
)(
  input  logic clk_i,
  input  logic s_rst_i,

  input  logic pin_i,
  output logic pin_state_o
);

// pin_i асинхронный сигнал. Нужно его пересинхронизировать:

logic [2:0] pin_d;

always_ff @( posedge clk_i )
  begin
    pin_d[0] <= pin_i;
    pin_d[1] <= pin_d[0];
    pin_d[2] <= pin_d[1];
  end

logic [DB_CNT_W-1:0] db_counter;
logic                pin_differ;

logic                db_counter_max;

// 1 только когда счетчик станет '1111...11
assign db_counter_max = ( &db_counter );

// 0 -- когда пин не меняется за 2 такта
// 1 -- пин на двух тактах имеет разное значение
assign pin_differ = pin_d[2] ^ pin_d[1];

always_ff @( posedge clk_i )
  if( s_rst_i )
    db_counter <= '0;
  else
    begin
      if( db_counter_max || pin_differ )
        db_counter <= '0;
      else
        db_counter <= db_counter + (DB_CNT_W)'(1);
    end

always_ff @( posedge clk_i )
  if( s_rst_i )
    pin_state_o <= 1'b0;
  else
    if( db_counter_max )
      pin_state_o <= pin_d[2];

endmodule
