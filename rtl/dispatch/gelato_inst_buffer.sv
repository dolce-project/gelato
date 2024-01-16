// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction buffer of each warp in the Gelato GPU.

module gelato_inst_buffer (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_idecode_ibuffer_if.slave  inst_decoded_data,
  gelato_ibuffer_warpskd_if.master buffer
);
  gelato_idecode_ibuffer_if warp_inst_decoded_data[`WARP_NUM];
  logic warp_pop_enabled[`WARP_NUM];
  logic warp_full[`WARP_NUM];
  logic warp_empty[`WARP_NUM];
  inst_t warp_tail_data[`WARP_NUM];

  generate
    for (genvar i = 0; i < WARPS_PER_SM; i++) begin : gen_warp_buffer
      assign warp_inst_decoded_data[i].valid =
        inst_decoded_data.valid &&
        inst_decoded_data.warp_num == i;
      assign warp_inst_decoded_data[i].inst = inst_decoded_data.inst;

      assign warp_pop_enabled[i] = buffer.caught[i];
      assign buffer.valid[i] = !warp_empty[i];
      assign buffer.inst[i] = warp_tail_data[i];

      gelato_warp_inst_buffer_unit inst_buffer_unit (
        .clk  (clk),
        .rst_n(rst_n),
        .rdy  (rdy),

        .pop_enabled      (warp_pop_enabled[i]),
        .full             (warp_full[i]),
        .empty            (warp_empty[i]),
        .tail_data        (warp_tail_data[i]),
        .inst_decoded_data(inst_decoded_data),
      );

      always_ff @(posedge clk or negedge rst_n) begin
        if (buffer.caught[i]) begin
          buffer.caught[i] <= 0;
        end
      end
    end
  endgenerate
endmodule
