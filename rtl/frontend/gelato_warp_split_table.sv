// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the split table of each warp in the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_warp_split_table (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_split_table_select_pc_if.master select,
  gelato_split_table_update_pc_if.slave update
);
  import gelato_types::*;

  split_table_entry_t split_table[`SPLIT_TABLE_NUM];

  split_table_num_t next_table_num;
  split_table_num_t last_table_num;

  assign update.thread_mask = split_table[update.split_table_num].thread_mask;

  always_comb begin
    for (split_table_num_t i = 0; i != `SPLIT_TABLE_MAX_NUM; i++) begin
      split_table_num_t j = last_table_num + i;
      if (split_table[j].valid) begin
        next_table_num = j;
        break;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      last_table_num <= 0;
      select.pc <= 0;
      select.split_table_num <= 0;
    end else if (rdy && update.valid) begin
      // Update the split table
      split_table[update.split_table_num].active <= !update.stall;
      split_table[update.split_table_num].current_pc <= update.pc;

      // Select the next entry
      select.split_table_num <= next_table_num;
      select.pc <= split_table[next_table_num].current_pc;
      select.valid <= split_table[next_table_num].valid & split_table[next_table_num].active;
      split_table[next_table_num].active <= 0;
      last_table_num <= next_table_num;
    end
  end
endmodule
