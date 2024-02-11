// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the fetch scheduler of the Gelato GPU. It chooses a warp in the pc table when the fetch unit is ready to fetch a new instruction.

`include "gelato_macros.svh"
`include "gelato_types.svh"

import gelato_types::*;

module gelato_fetch_scheduler (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // Get the pc of each warp
  gelato_pctable_fetchskd_if.slave pc_table,
  // Receive the buffer information
  gelato_ibuffer_fetchskd_if.slave buffer_status,

  // Send the pc to the fetch unit
  output logic dout_valid,
  input logic dout_ready,
  output pc_info_t dout
);
  //============================================================================
  // Information of each warp. delivered by the pc table and instruction buffer
  //============================================================================
  logic [`WARP_NUM-1:0] valid;
  logic [`WARP_NUM-1:0] warp_disabled;

  generate
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_warp_valid
      assign valid[i] = pc_table.valid[i] && !warp_disabled[i] && buffer_status.available[i];
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      warp_disabled <= 0;
    end else if (pc_table.activate_valid) begin
      warp_disabled[pc_table.activate_warp_num] <= 0;
    end
  end

  //============================================================================
  // Selected warp number, generated by the round arbiter
  //============================================================================
  warp_num_t selected_warp_q, selected_warp_d;

  gelato_round_arbiter #(
    .PORT_NUM_WIDTH(`WARP_NUM_WIDTH),
    .STEP_LENGTH(2)
  ) round_arbiter (
    .clk(clk),
    .rst_n(rst_n),
    .req(valid),
    .selected(selected_warp_d)
  );

  assign dout_valid = valid[selected_warp_q];
  assign dout.pc = pc_table.pc[selected_warp_q];
  assign dout.warp_num = selected_warp_q;
  assign dout.split_table_num = pc_table.split_table_num[selected_warp_q];

  //============================================================================
  // The state machine to deliver selected pc
  //============================================================================
  typedef enum logic { GENERATE_PC, WAIT_READY } state_t;
  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= GENERATE_PC;
    end else begin
      case (state)
        GENERATE_PC: begin
          if (dout_valid) begin
            state <= WAIT_READY;
          end
        end
        WAIT_READY: begin
          if (dout_ready) begin
            state <= GENERATE_PC;
            selected_warp_q <= selected_warp_d;
          end
        end
        default: begin
          $fatal(0, "gelato_fetch_scheduler: Invalid state");
        end
      endcase
    end
  end
endmodule
