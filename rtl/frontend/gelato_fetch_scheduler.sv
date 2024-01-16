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

  typedef enum {
    GENERATE_PC,
    WAIT_CAUGHT
  } status_t;
  status_t status;

  // Selected warp number and last number (used to generate new num)
  warp_num_t next_warp;
  warp_num_t last_warp;

  logic warp_disabled[`WARP_NUM];

  // Generate new selected warp number
  always_comb begin
    warp_num_t i = last_warp;
    repeat (`WARP_MAX_NUM) begin
      if (pc_table.valid[i] & !warp_disabled[i]) begin
        next_warp = i;
        break;
      end
      i++;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status <= GENERATE_PC;
      last_warp <= 0;
      inst_pc.valid <= 0;
      inst_pc.caught <= 0;
      foreach (warp_disabled[i]) begin
        warp_disabled[i] <= 0;
      end
    end else if (rdy) begin
      case (status)
        GENERATE_PC: begin
          if (pc_table.valid[next_warp]) begin
            // Send the pc to the fetch unit
            inst_pc.valid <= 1;
            inst_pc.pc <= pc_table.pc[next_warp];
            inst_pc.warp_num <= next_warp;
            inst_pc.split_table_num <= pc_table.split_table_num[next_warp];

            // Update status
            status <= WAIT_CAUGHT;
          end
        end
        WAIT_CAUGHT: begin
          if (inst_pc.caught) begin
            warp_disabled[inst_pc.warp_num] <= 1;

            // Update last warp number and status
            last_warp <= next_warp;
            status <= GENERATE_PC;

            // Invalidate the pc table entry
            inst_pc.caught <= 0;
            inst_pc.valid <= 0;
          end
        end
        default: begin
          $fatal(0, "gelato_fetch_scheduler: Invalid status");
        end
      endcase

      if (pc_table.activate_valid) begin
        warp_disabled[pc_table.activate_warp_num] <= 0;
      end
    end
  end
endmodule
