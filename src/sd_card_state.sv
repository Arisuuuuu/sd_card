module sd_card_state (
    input logic clk,
    input logic res_n,

    //spi_init_controller
    output logic [47:0] spi_init_cmd_data,
    output logic spi_init_cmd,
    input logic spi_init_busy,
    input logic spi_init_error,
    input logic [47:0] spi_init_response

    //spi controller
    //TODO

);

  typedef enum {START, CMD0, CMD8, CMD58, ACMD41, INIT_DONE} init_state_t;
  typedef enum {IDLE, TX, RX, WAIT} state_t;

  init_state_t init_state = START;
  state_t state = IDLE;
  //init state machine
  always_ff @(posedge clk or negedge res_n) begin
    if(~res_n) begin
      init_state <= START;
    end else begin
      case(init_state)
        START: begin

        end

        CMD0: begin

        end

        CMD8: begin

        end

        CMD58: begin

        end

        ACMD41: begin

        end

        INIT_DONE: begin

        end



    end
  end

  //state machine for read operations
  always_ff @(posedge clk or negedge res_n) begin
    if(~res_n) begin
      state <= IDLE;
    end else begin
      //TODO Read operation
    end
  end
endmodule
