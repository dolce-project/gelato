// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the split table of the Gelato GPU. Split table is the key module in a SIMT execution model.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_split_table (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_pctable_fetchskd_if.master pc_table,
  gelato_idecode_split_if.slave split_data
);
  import gelato_types::*;

  gelato_split_table_select_pc_if select[`WARP_NUM];
  gelato_split_table_update_pc_if update[`WARP_NUM];

  assign split_data.thread_mask = update[split_data.warp_num].thread_mask;

  generate;
    for (genvar i = 0; i < `WARP_NUM; i++) begin: gen_split_table
      // Select update data
      assign update[i].valid = split_data.valid & (split_data.warp_num == i);
      assign update[i].stall = split_data.stall;
      assign update[i].pc = split_data.updated_pc;
      assign update[i].split_table_num = split_data.split_table_num;

      // PC Table
      assign pc_table.valid[i] = select[i].valid;
      assign pc_table.pc[i] = select[i].pc;
      assign pc_table.split_table_num[i] = select[i].split_table_num;

      // Create split table for i-th warp
      gelato_warp_split_table split_table (
        .clk(clk),
        .rst_n(rst_n),
        .rdy(rdy),

        .select(select[i]),
        .update(update[i])
      );
    end
  endgenerate
endmodule
