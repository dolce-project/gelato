// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the testbench of the FIFO used in the Gelato GPU.

module top (
  input logic clk,
  input logic rst_n
);
  integer count = 0;

  logic din_valid, dout_valid;
  integer din, dout;
  logic din_ready, dout_ready;

  gelato_fifo #(
    .WIDTH(2),
    .T(integer)
  ) fifo (
    .clk(clk),
    .rst_n(rst_n),
    .din_valid(din_valid),
    .din(din),
    .din_ready(din_ready),
    .dout_valid(dout_valid),
    .dout(dout),
    .dout_ready(dout_ready)
  );
  always_comb begin
    case (count)
      1: begin
        din_valid = 1;
        din = 1;
      end
      2: begin
        din_valid = 0;
      end
      3: begin
        din_valid = 1;
        din = 2;
        dout_ready = 1;
      end
      4: begin
        din = 3;
        dout_ready = 0;
      end
      5: begin
        din = 4;
      end
      6: begin
        din = 5;
      end
      default: begin
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
    end else begin
      $display(
        "din_valid=%0d, din=%0d, din_ready=%0d, dout_valid=%0d, dout=%0d, dout_ready=%0d",
        din_valid, din, din_ready, dout_valid, dout, dout_ready);
      count <= count + 1;
    end
  end
endmodule
