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
  gelato_split_table_update_pc_if.slave  update,
  gelato_init_if.slave    init
);
  import gelato_types::*;

  split_table_entry_t split_table[`SPLIT_TABLE_NUM];

  split_table_num_t next_table_num;
  split_table_num_t last_table_num;
  logic init_done;

  assign update.thread_mask = split_table[update.split_table_num].thread_mask;

  always_comb begin
    split_table_num_t i = last_table_num + 1;
    repeat (`SPLIT_TABLE_NUM) begin
      if (split_table[i].valid) begin
        next_table_num = i;
        break;
      end
      i++;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      init_done <= 0;
      last_table_num <= 0;
      select.pc <= 0;
      select.split_table_num <= 0;

      // Initialize the split table
      if (init.valid) begin
        split_table[0].valid <= 1;
        split_table[0].active <= 1;
        split_table[0].current_pc <= init.pc;
        split_table[0].thread_mask <= {`THREAD_NUM{1'b1}};
        // split_table_num_t i = 0;
        // repeat (`SPLIT_TABLE_NUM - 1) begin
        //   split_table[++i].valid <= 0;
        // end
      end
    end else if (rdy) begin
      // Update the pc table entry
      select.split_table_num <= next_table_num;
      select.pc <= split_table[next_table_num].current_pc;
      select.valid <= split_table[next_table_num].valid & split_table[next_table_num].active;
      last_table_num <= next_table_num;

      if (update.valid) begin
        // Update the split table
        split_table[update.split_table_num].active <= !update.stall;
        split_table[update.split_table_num].current_pc <= update.pc;
      end
    end
  end
endmodule
