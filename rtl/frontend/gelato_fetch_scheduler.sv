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
  input logic ifetch_ready,
  gelato_fetchskd_ifetch_if.master selected_pc
);
  import gelato_types::*;

  warp_num_t selected_warp;

  always_comb begin
    for (warp_num_t i = 0; i < WARP_NUM; i++) begin
      if (pc_table.valid[selected_warp + i]) begin
        selected_warp += i;
        break;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      selected_warp <= 0;
      selected_pc.valid <= 0;
    end else if (rdy && ifetch_ready) begin
      selected_pc.valid <= pc_table.valid[selected_warp];
      selected_pc.pc <= pc_table.pc[selected_warp];
      selected_pc.warp <= selected_warp;
      selected_pc.split_table_num <= pc_table.split_table_num[selected_warp];
    end
  end
endmodule
