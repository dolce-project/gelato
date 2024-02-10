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

  gelato_init_warp_if.slave_split_table init,

  gelato_pctable_fetchskd_if.master pc_table,
  gelato_idecode_split_if.slave split_data
);
  import gelato_types::*;

  gelato_split_table_select_pc_if select[`WARP_NUM];
  gelato_split_table_update_pc_if update[`WARP_NUM];
  gelato_init_warp_if warp_init[`WARP_NUM];
  warp_num_t warp_num[`WARP_NUM];

  logic init_all_warp;
  warp_num_t init_max_warp_num;
  thread_num_t init_last_thread_num;

  assign init_all_warp = init.workers[`WARP_NUM_WIDTH+`THREAD_NUM_WIDTH];
  assign init_max_warp_num = init.workers[`WARP_NUM_WIDTH+`THREAD_NUM_WIDTH-1:`THREAD_NUM_WIDTH];
  assign init_last_thread_num = init.workers[`THREAD_NUM_WIDTH-1:0];

  generate
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_split_table
      assign warp_num[i] = i;

      // Select update data
      assign update[i].valid = split_data.valid & (split_data.warp_num == i);
      assign update[i].stall = split_data.stall;
      assign update[i].pc = split_data.updated_pc;
      assign update[i].split_table_num = split_data.split_table_num;

      // PC Table
      assign pc_table.valid[i] = select[i].valid;
      assign pc_table.pc[i] = select[i].pc;
      assign pc_table.split_table_num[i] = select[i].split_table_num;

      // Init PC
      assign warp_init[i].pc = init.pc;
      assign warp_init[i].valid = init.valid & warp_init[i].workers != {`THREAD_NUM{1'b0}};

      always_comb begin
        if (init_all_warp || warp_num[i] < init_max_warp_num) begin
          warp_init[i].workers = {`THREAD_NUM{1'b1}};
        end else if (warp_num[i] == init_max_warp_num) begin
          warp_init[i].workers = {{(32 - `THREAD_NUM_WIDTH) {1'b0}}, init_last_thread_num};
        end else begin
          warp_init[i].workers = 0;
        end
      end

      // Create split table for i-th warp
      gelato_warp_split_table split_table (
        .clk  (clk),
        .rst_n(rst_n),
        .rdy  (rdy),

        .select(select[i]),
        .update(update[i]),
        .init  (warp_init[i])
      );

      always_comb begin
        if (split_data.warp_num == i) begin
          split_data.thread_mask = update[i].thread_mask;
        end
      end
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_table.activate_valid <= 0;
    end else if (rdy) begin
      if (split_data.valid) begin
        pc_table.activate_valid <= split_data.activate;
        pc_table.activate_warp_num <= split_data.warp_num;
      end else begin
        pc_table.activate_valid <= 0;
      end
    end
  end
endmodule
