// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the handshake protocol (valid-ready) used in the Gelato GPU.

module gelato_handshake #(
  type T = logic
) (
  input logic clk,
  input logic rst_n,

  input logic din_valid,
  input T din,
  output logic din_ready,

  output logic dout_valid,
  output T dout,
  input logic dout_ready
);

  //=========================================================================
  // The handshake is implemented by a fifo of depth 2.
  //=========================================================================
  gelato_fifo #(
    .WIDTH(1),
    .T(T)
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
endmodule
