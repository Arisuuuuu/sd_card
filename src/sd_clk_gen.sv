module sd_clk_gen (
    input logic clk,
    output logic [7:0] clk_out
);

  always@(posedge clk) begin
    clk_out <= clk_out + 1;
  end
endmodule