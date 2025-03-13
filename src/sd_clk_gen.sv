module sd_clk_gen (
    input logic clk,
    input logic res_n,
    input logic speed,  //low => 0, about 400Khz, high => 1 50Mhz,
    output logic sd_clk = 0
);
  integer count = 0;  //at 50Mhz it needs 125 cycles to get to 400Khz

  always_ff @(posedge clk or negedge res_n) begin : clock_proc
    if (!res_n) count <= 0;
    else begin
      count <= count + 1;
      if (speed == 1) sd_clk <= ~sd_clk;
      else begin
        if (count == 61) begin
          sd_clk <= ~sd_clk;
          count  <= 0;
        end
      end
    end
  end
endmodule

