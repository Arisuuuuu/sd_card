module sd_spi_output_init (
    input logic clk,
    input logic res_n,


    //controll interface
    input logic [47:0] spi_cmd_data,
    input logic spi_cmd,
    input logic [9:0] spi_bytes_expected,
    output logic spi_busy,
    output logic spi_error,
    output logic [7:0] spi_response,  //R2 not supported
    output logic spi_avail,  //signal that new byte is available
    output logic spi_rd,

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

  (* DONT_TOUCH = "TRUE" *) state_t state = IDLE;

  //some registers needed
  logic [47:0] spi_cmd_reg;
  logic [7:0] spi_resp_reg;
  integer current_bit;
  logic [9:0] current_byte;  //delete?

  always_ff @(posedge clk or negedge res_n) begin
    if (~res_n) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          spi_busy  <= 1'b0;
          spi_avail <= 1'b0;
          card_CS   <= 1'b1;
          card_MOSI <= 1'b1;
          if (spi_cmd) begin
            spi_busy <= 1'b1;
            spi_cmd_reg <= spi_cmd_data;
            state <= SEND_CMD;
            current_bit <= 47;
            current_byte <= spi_bytes_expected;  //+1 maybe
          end
        end

        SEND_CMD: begin
          card_CS <= 1'b0;
          card_MOSI <= spi_cmd_reg[current_bit];
          current_bit <= current_bit - 1;
          if (current_bit == -1) begin
            current_bit <= 7;
            state <= WAIT_RESPONSE;
          end
        end

        WAIT_RESPONSE: begin
          card_MOSI <= 1'b1;
          if (card_MISO == 1'b0) begin
            spi_resp_reg[current_bit] <= card_MISO;
            state <= RECV_RESPONSE;
            current_bit <= current_bit - 1;
          end
        end

        RECV_RESPONSE: begin
          spi_avail <= 1'b0;
          spi_resp_reg[current_bit] <= card_MISO;
          current_bit <= current_bit - 1;
          if (current_bit == -1) begin
            spi_response <= spi_resp_reg;
            spi_avail <= 1'b1;
            current_bit <= 7;
            current_byte <= current_byte - 1;
            if (current_byte == 0) begin
              state <= IDLE;
            end
          end
        end
        default: spi_error <= 1'b1;
      endcase

    end
  end

endmodule
