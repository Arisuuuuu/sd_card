module sd_top(
  //res_n
  input logic rst,
  //clk
  input logic clk,
  //mosi
  input logic sd_data_in,
  //miso
  output logic sd_data_out,
  //cs
  output logic sd_cs,

  output logic sd_clk,

  output logic led1,

  output logic led2
);

  logic sd_clk_gen;
  logic speed;

  logic [47:0] spi_cmd_data;
  logic spi_cmd;
  logic spi_busy;
  logic spi_error;
  logic [7:0] spi_response;
  logic spi_avail;
  logic [9:0] spi_bytes;

  logic sd_busy;
  logic sd_error;

  sd_clk_gen sd_clock(
    .res_n(rst),
    .clk(clk),
    .sd_clk(sd_clk_gen),
    .speed(speed)
  );

  sd_spi_output_init spi_init(
    .clk(sd_clk_gen),
    .res_n(rst),
    .spi_cmd_data(spi_cmd_data),
    .spi_cmd(spi_cmd),
    .spi_busy(spi_busy),
    .spi_error(spi_error),
    .spi_response(spi_response),
    .spi_avail(spi_avail),
    .spi_bytes_expected(spi_bytes),
    .card_MOSI(sd_data_out),
    .card_MISO(sd_data_in),
    .card_CS(sd_cs)
  );

  sd_card_state sd_state(
    .clk(sd_clk_gen),
    .res_n(rst),
    .sd_speed(speed),
    .spi_cmd_data(spi_cmd_data),
    .spi_cmd(spi_cmd),
    .spi_response_len(spi_bytes),
    .spi_busy(spi_busy),
    .spi_error(spi_error),
    .spi_avail(spi_avail),
    .sd_busy(sd_busy), //some light?
    .sd_error(sd_error) //different light
  );

  always_comb begin
    led1 = ~sd_busy;
    led2 = ~sd_error;
    sd_clk = sd_clk_gen;
  end



endmodule
