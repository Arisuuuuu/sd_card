module sd_spi_output_init (
    input logic clk,
    input logic res_n,


    //controll interface
    input logic [47:0] spi_cmd_data,
    input logic spi_cmd,
    output logic spi_busy,
    output logic spi_error,
    output logic [47:0] spi_response,  //R2 not supported

    //card interface
    output logic card_MOSI,
    input  logic card_MISO,
    output logic card_CS
);

  typedef enum {
    IDLE,
    SEND_CMD,
    WAIT_RESPONSE,
    RECV_RESPONSE
  } state_t;

  state_t state = IDLE;

  //some registers needed
  logic [47:0] spi_cmd_reg;
  logic [47:0] spi_resp_reg;
  integer current_bit;

  always_ff @(posedge clk or negedge res_n) begin
    if (~res_n) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          spi_busy <= 1'b0;
          if (spi_cmd) begin
            spi_busy <= 1'b1;
            spi_cmd_reg <= spi_cmd_data;
            state <= SEND_CMD;
            current_bit <= 47;
          end
        end

        SEND_CMD: begin
          card_CS <= 1'b1;
          card_MOSI <= spi_cmd_reg[current_bit];
          current_bit <= current_bit - 1;
          if (current_bit == -1) begin
            state <= WAIT_RESPONSE;
            current_bit <= 47;
            card_CS <= 1'b0;
          end
        end

        WAIT_RESPONSE: begin
          if (card_MISO == 1'b0) begin
            spi_resp_reg[current_bit] <= card_MISO;
            state <= RECV_RESPONSE;
            current_bit <= current_bit - 1;
          end
        end

        RECV_RESPONSE: begin
          spi_resp_reg[current_bit] <= card_MISO;
          current_bit <= current_bit - 1;
          if (current_bit == -1) begin
            state <= IDLE;
            spi_response <= spi_resp_reg;
          end
        end
        default: spi_error <= 1'b1;
      endcase

    end
  end


endmodule
