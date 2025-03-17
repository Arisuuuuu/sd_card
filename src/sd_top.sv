module sd_top (
    //res_n
    input  logic rst,
    //clk
    input  logic clk,
    //mosi
    input  logic sd_data_in,
    //miso
    output logic sd_data_out,
    //cs
    output logic sd_cs,

    output logic sd_clk,

    output logic led1,

    output logic led2
);

  logic clk_used;
  logic [7:0] clk_gen;
  logic speed;

  (* DONT_TOUCH = "TRUE" *) logic [47:0] spi_cmd_data;
  logic spi_cmd;
  logic spi_busy;
  logic spi_error;
  logic [7:0] spi_response;
  logic spi_avail;
  logic [9:0] spi_bytes;

  logic sd_busy;
  logic sd_error;

  BUFGMUX_CTRL BUFGMUX_inst (
      .O (clk_used),
      .I0(clk_gen[7]),
      .I1(clk),
      .S (speed)
  );

  sd_clk_gen sd_clock (
      .clk(clk),
      .clk_out(clk_gen)
  );

  sd_spi_output_init spi_init (
      .clk(clk_used),
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

  sd_card_state sd_state (
      .clk(clk_used),
      .res_n(rst),
      .sd_speed(speed),
      .spi_cmd_data(spi_cmd_data),
      .spi_cmd(spi_cmd),
      .spi_response_len(spi_bytes),
      .spi_busy(spi_busy),
      .spi_error(spi_error),
      .spi_avail(spi_avail),
      .sd_busy(sd_busy),  //some light?
      .sd_error(sd_error)  //different light
  );

  always_comb begin
    led1   = ~sd_busy;
    led2   = ~sd_error;
    sd_clk = clk_used;
  end



endmodule
