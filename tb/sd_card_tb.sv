`timescale 1ns / 1ps

module sd_card_tb ();


  logic clk = 0;
  logic sd_clk;
  logic res_n = 0;


  always #10 clk = ~clk;

  initial begin
    #1000000 $finish;
  end

  initial begin
    $dumpfile("sd_card_tb.vcd");
    $dumpvars(0, sd_card_tb);
  end

  sd_clk_gen sd_clock (
      .res_n(res_n),
      .clk(clk),
      .sd_clk(sd_clk)
  );
endmodule
