module sd_card_state (
    input logic clk,
    input logic res_n,

    //sd_clk_gen
    output logic sd_speed,

    //spi_init_controller
    output logic [47:0] spi_cmd_data,
    output logic spi_cmd,
    output logic [9:0] spi_response_len,
    input logic spi_busy,
    input logic spi_error,
    input logic [7:0] spi_response,
    input logic spi_avail,


    //to outside
    output logic sd_busy,
    output logic sd_error
    //input logic [31:0] sd_rd_addr,
    //input logic sd_rd

    //TODO queue or ram to load block

);

  typedef enum {
    START,
    CMD0,
    CMD17,  //read
    CMD8,
    CMD58,
    ACMD41,
    WAIT,
    IDLE,
    R1,
    R3,
    R7,
    DATA_RESPONSE,
    DATA,
    ERROR
  } state_t;

  state_t state = START;
  state_t state_after_response = IDLE;
  state_t expected_response = R1;

  logic [7:0] resp_byte = 8'd0;
  integer response_byte_cnt = 0;

  logic ver1_card = 0;
  logic cmd58_sent = 0;
  //state machine
  always_ff @(posedge clk or negedge res_n) begin
    if (~res_n) begin
      state <= START;
    end else begin
      case (state)
        START: begin
          sd_busy <= 1'b1;
          sd_error <= 1'b0;
          state <= CMD0;
          spi_cmd <= 1'b0;
          sd_speed <= 1'b0;
          //spi_rd <= 1'b0;
        end

        WAIT: begin
          spi_cmd <= 1'b0;
          if (spi_avail) begin
            state <= expected_response;
            resp_byte <= spi_response;
            response_byte_cnt <= response_byte_cnt - 1;
          end
        end

        R1: begin
          if (resp_byte == 8'd0) begin
            state <= state_after_response;
          end else begin
            state <= ERROR;
          end
        end

        R3: begin  //could check OCR
          if (response_byte_cnt == 4) begin
            if (resp_byte == 8'd0) begin
              state <= WAIT;
            end else begin
              state <= ERROR;
            end
          end else if (response_byte_cnt == 0) begin
            state <= state_after_response;
          end else begin
            state <= WAIT;
          end
        end

        R7: begin
          if (response_byte_cnt == 4) begin
            if (resp_byte != 8'd0) begin
              if (resp_byte == 8'b00000100) begin
                ver1_card <= 1'b1;
                state <= WAIT;
              end else begin
                state <= ERROR;
              end
            end else begin
              state <= WAIT;
            end
          end else if (response_byte_cnt == 0) begin
            state <= state_after_response;
          end else begin
            state <= WAIT;
          end
        end

        CMD0: begin
          spi_cmd <= 1'b1;
          spi_cmd_data <= 48'h4000000095;
          spi_response_len <= 9'd1;
          response_byte_cnt <= 1;
          expected_response <= R1;
          state_after_response <= CMD8;
          state <= WAIT;

        end

        CMD8: begin
          spi_cmd <= 1'b1;
          spi_cmd_data <= 48'h480001aa87;
          spi_response_len <= 9'd5;
          response_byte_cnt <= 5;
          expected_response <= R7;
          state_after_response <= CMD58;
          state <= WAIT;
        end

        CMD58: begin
          spi_cmd <= 1'b1;
          spi_cmd_data <= {8'h5a, 32'h0, 7'h66, 1'h1};
          spi_response_len <= 9'd5;
          response_byte_cnt <= 5;
          expected_response <= R3;
          if (cmd58_sent) begin
            state_after_response <= IDLE;
            sd_speed <= 1'b1;
          end else begin
            state_after_response <= ACMD41;
          end
          state <= WAIT;
        end

        ACMD41: begin
          cmd58_sent <= 1'b1;
          spi_cmd <= 1'b1;
          spi_cmd_data <= {8'h69, 8'h40, 8'h00, 8'h00, 8'h00, 8'hff};
          spi_response_len <= 9'd1;
          response_byte_cnt <= 1;
          expected_response <= R1;
          if (ver1_card) begin
            state_after_response <= IDLE;
            sd_speed <= 1'b1;
          end else begin
            state_after_response <= CMD58;
          end
        end

        ERROR: begin
          sd_error <= 1'b1;
        end

        IDLE: begin
          sd_busy <= 1'b0;
          sd_error <= 1'b0;
          spi_cmd <= 1'b0;
          spi_cmd_data <= 48'd0;
          spi_response_len <= 9'd0;

        end


        DATA: begin

        end

        DATA_RESPONSE: begin

        end

        default: begin
          state <= ERROR;
          sd_error <= 1'b1;
        end

      endcase
    end
  end

endmodule
