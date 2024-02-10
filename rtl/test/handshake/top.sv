
// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the testbench of the handshake used in the Gelato GPU.

module top (
  input logic clk,
  input logic rst_n
);
  integer count = 0;

  logic din_valid, dout_valid;
  integer din, dout;
  logic din_ready, dout_ready;

  gelato_handshake #(
    .T(integer)
  ) handshake (
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid),
    .din(din),
    .din_ready(din_ready),
    .dout_valid(dout_valid),
    .dout(dout),
    .dout_ready(dout_ready)
  );

  typedef enum logic [2:0] {
    IDLE,
    SENDING,
    FINISH_SENDING,
    RECEIVING,
    FINISH_RECEIVING
  } state_t;
  state_t sender_state, receiver_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sender_state   <= IDLE;
      receiver_state <= IDLE;
    end else begin
      case (sender_state)
        IDLE: begin
          sender_state <= SENDING;
        end
        SENDING: begin
          if (!din_ready) begin
            sender_state <= IDLE;
          end else begin
            din_valid <= 1;
            din <= $urandom_range(0, 100);
            sender_state <= FINISH_SENDING;
          end
        end
        FINISH_SENDING: begin
          if (din_ready) begin
            $display("Sent %d", din);
            din_valid <= 0;
            sender_state <= IDLE;
          end
        end
        default: begin
        end
      endcase

      case (receiver_state)
        IDLE: begin
          dout_ready <= 1;
          receiver_state <= RECEIVING;
        end
        RECEIVING: begin
          if (dout_valid) begin
            $display("Received %d", dout);
            dout_ready <= 0;
            receiver_state <= FINISH_RECEIVING;
          end
        end
        FINISH_RECEIVING: begin
          receiver_state <= IDLE;
        end
        default: begin
        end
      endcase
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
    end else begin
      count <= count + 1;
    end
  end
endmodule
