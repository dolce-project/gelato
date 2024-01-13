// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction decode unit of the Gelato GPU.

`include "gelato_macros.svh"

module gelato_inst_decode (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_ifetch_idecode_if.slave inst_raw_data,
  gelato_idecode_split_if.master split_data,
  gelato_idecode_ibuffer_if.master inst_decoded_data
);
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      inst_decoded_data.valid <= 1'b0;
      inst_decoded_data.inst <= 0;
    end else if (rdy && inst_raw_data.valid) begin
      inst_decoded_data.valid <= 1;
      inst_decoded_data.pc <= inst_raw_data.pc;
      inst_decoded_data.warp_num <= inst_raw_data.warp_num;
      // TODO: Decode the instruction
    end
  end
endmodule
