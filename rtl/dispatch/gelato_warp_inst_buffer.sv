// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction buffer of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_warp_inst_buffer (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_inst_buffer_if.master warp_data,
  gelato_idecode_ibuffer_if.slave inst_decoded_data
);
  import gelato_types::*;

  logic  push_enabled;
  inst_t push_data;

  gelato_queue #(
    .T(inst_t),
    .WIDTH(`BUFFER_SIZE_WIDTH)
  ) inst_queue (
    .clk  (clk),
    .rst_n(rst_n),
    .rdy  (rdy),
    .push_enabled(push_enabled),
    .push_data(push_data),
    .pop_enabled(warp_data.pop_enabled),
    .tail_data  (warp_data.tail_data),
    .empty(warp_data.empty),
    .full (warp_data.full)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      push_enabled <= 0;
    end else if (rdy) begin
      if (inst_decoded_data.valid) begin
        if (warp_data.full) begin
          $fatal(0, "Warp instruction buffer is full!");
        end
        push_enabled <= 1;
        push_data    <= inst_decoded_data.inst;
      end else begin
        push_enabled <= 0;
      end
    end
  end
endmodule
