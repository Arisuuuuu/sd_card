`timescale 1ns / 1ps

module sd_card_tb ();


  logic clk = 0;
  logic sd_clk;
  logic res_n = 0;
  logic speed = 0;

  //spi_init_output ports
  logic [47:0] spi_cmd_data;
  logic spi_cmd;
  logic spi_busy;
  logic spi_error;
  logic [47:0] spi_response;

  logic card_MOSI;
  logic card_MISO;
  logic card_CS;

  //clock gen
  always #10 clk = ~clk;

  initial begin
    res_n = 1;
    speed = 0;
    #100;
    spi_cmd <= 1'b1;
    spi_cmd_data <= 48'h4000000095;
    #10000;
    card_MISO <= 1'b0;

    #10000000 $finish;
  end

  initial begin
    $dumpfile("sd_card_tb.vcd");
    $dumpvars(0, sd_card_tb);
  end

  sd_clk_gen sd_clock (
      .res_n(res_n),
      .clk(clk),
      .sd_clk(sd_clk),
      .speed(speed)
  );

  sd_spi_output_init spi_init (
      .clk(sd_clk),
      .res_n(res_n),
      .spi_cmd_data(spi_cmd_data),
      .spi_cmd(spi_cmd),
      .spi_busy(spi_busy),
      .spi_error(spi_error),
      .spi_response(spi_response),
      .card_MOSI(card_MOSI),
      .card_MISO(card_MISO),
      .card_CS(card_CS)
  );
endmodule
