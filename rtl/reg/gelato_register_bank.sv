// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the register bank of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

`define THREAD_REG_INDEX (i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH

module gelato_register_bank (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_register_bank_update_if.slave update
);
  import gelato_types::*;

  warp_reg_t data[`WARP_NUM][`BANK_REG_NUM];
  warp_reg_t write_data;

  generate
    for (genvar i = 0; i < `THREAD_NUM; i++) begin : gen_write_data
      assign write_data[`THREAD_REG_INDEX] = update.thread_mask[i] ?
                update.write_data[`THREAD_REG_INDEX] :
                data[update.warp_num][update.reg_num[`BANK_REG_INDEX]][`THREAD_REG_INDEX];
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    end else if (rdy) begin
      if (update.write) begin
        data[update.warp_num][update.reg_num[`BANK_REG_INDEX]] <= write_data;
      end else begin
        update.data <= data[update.warp_num][update.reg_num[`BANK_REG_INDEX]];
      end
    end
  end
endmodule
