// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the scoreboard of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_scoreboard (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_scoreboard_warpskd_if.master record
);
  import gelato_types::*;

  reg_num_t dirty_regs[`WARP_NUM][`SCOREBOARD_SIZE];
  assign record.regs = dirty_regs;

  logic full[`WARP_NUM];
  integer empty_slot[`WARP_NUM];

  generate;
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_warp_full
      always_comb begin
        full[i] = 1;
        foreach (dirty_regs[i,j]) begin
          if (dirty_regs[i][j] == 0) begin
            full[i] = 0;
            empty_slot[i] = j;
            break;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      foreach (dirty_regs[i,j]) begin
        dirty_regs[i][j] <= 0;
      end
    end else begin
      if (record.new_reg != 0) begin
        if (full[record.warp_num]) begin
          $fatal(0, "Scoreboard full!");
        end
        dirty_regs[record.warp_num][empty_slot[record.warp_num]] <= record.new_reg;
        record.new_reg <= 0;
      end
    end
  end
endmodule
