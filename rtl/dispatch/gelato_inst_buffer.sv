// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction buffer of each warp in the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_inst_buffer (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_idecode_ibuffer_if.slave  inst_decoded_data,
  gelato_ibuffer_warpskd_if.master buffer
);
  import gelato_types::*;

  gelato_idecode_ibuffer_if warp_inst_decoded_data[`WARP_NUM];
  gelato_inst_buffer_if warp_data[`WARP_NUM];

  generate
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_warp_buffer
      assign warp_inst_decoded_data[i].valid =
        inst_decoded_data.valid &&
        inst_decoded_data.inst.warp_num == i;
      assign warp_inst_decoded_data[i].inst = inst_decoded_data.inst;

      assign warp_data[i].pop_enabled = buffer.caught[i];
      assign buffer.valid[i] = !warp_data[i].empty;
      assign buffer.inst[i] = warp_data[i].tail_data;

      gelato_warp_inst_buffer inst_buffer_unit (
        .clk  (clk),
        .rst_n(rst_n),
        .rdy  (rdy),

        .warp_data(warp_data[i]),
        .inst_decoded_data(warp_inst_decoded_data[i])
      );

      always_ff @(posedge clk or negedge rst_n) begin
        if (buffer.caught[i]) begin
          buffer.caught[i] <= 0;
        end
      end
    end
  endgenerate
endmodule
