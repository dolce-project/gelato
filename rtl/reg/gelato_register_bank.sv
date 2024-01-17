// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the register bank of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_register_bank (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_register_bank_update_if.slave update
);
  import gelato_types::*;

  warp_reg_t data[`WARP_NUM][`BANK_REG_NUM];

  always_comb begin
    if (update.write) begin
      data[update.reg_num[update.warp_num][`BANK_REG_INDEX]] = update.data;
    end else begin
      update.data = data[update.warp_num][update.reg_num[`BANK_REG_INDEX]];
    end
  end
endmodule
