// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the fetch scheduler of the Gelato GPU. It chooses a warp in the pc table when the fetch unit is ready to fetch a new instruction.

`include "gelato_types.svh"

module gelato_fetch_scheduler (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // Get the pc of each warp
  gelato_pctable_fetchskd_if.slave pc_table,

  // Send the selected pc to the fetch unit
  gelato_fetchskd_ifetch_if.master inst_pc
);
  import gelato_types::*;

  // Selected warp number and last number (used to generate new num)
  warp_num_t next_warp;
  warp_num_t last_warp;

  // Generate new selected warp number
  always_comb begin
    for (warp_num_t i = 0; i != `WARP_MAX_NUM; i++) begin
      if (pc_table.valid[last_warp+i]) begin
        next_warp = last_warp + i;
        break;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      last_warp <= 0;
      inst_pc.valid <= 0;
    end else if (rdy && inst_pc.ready) begin
      // Send the selected pc to the fetch unit
      inst_pc.valid <= pc_table.valid[next_warp];
      inst_pc.pc <= pc_table.pc[next_warp];
      inst_pc.warp_num <= next_warp;
      inst_pc.split_table_num <= pc_table.split_table_num[next_warp];

      // Update last warp number
      last_warp <= next_warp;
    end
  end
endmodule
