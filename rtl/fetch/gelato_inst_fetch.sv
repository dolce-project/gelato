// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction fetch unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

import gelato_types::*;

module gelato_inst_fetch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // I-Cache <-> I-Fetch
  gelato_l1_icache_if.slave icache_if,

  // Get the next pc from fetch scheduler
  input logic din_valid,
  output logic din_ready,
  input pc_info_t din,

  // Send the fetched instruction raw data to idecode
  output logic dout_valid,
  input logic dout_ready,
  output inst_raw_data_t dout
);
  //============================================================================
  // Transition of state
  //============================================================================
  typedef enum logic [1:0] {
    IDLE,
    WAIT_MEM,
    WAIT_READY
  } state_t;
  state_t state_q, state_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q <= IDLE;
    end else if (rdy) begin
      state_q <= state_d;
    end
  end

  //============================================================================
  // Condition of state transition
  //============================================================================
  always_comb begin
    case (state_q)
      IDLE: begin
        state_d = din_valid ? WAIT_MEM : IDLE;
      end
      WAIT_MEM: begin
        state_d = icache_if.ready ? WAIT_READY : WAIT_MEM;
      end
      WAIT_READY: begin
        state_d = dout_ready ? IDLE : WAIT_READY;
      end
      default: begin
        $fatal(0, "gelato_inst_fetch: Invalid state");
      end
    endcase
  end

  //============================================================================
  // Output
  //============================================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dout_valid <= 0;
    end else if (rdy) begin
      case (state_q)
        IDLE: begin
          dout_valid <= 0;
          dout_ready <= 1;
          dout.pc <= din.pc;
          dout.warp_num <= din.warp_num;
          dout.split_table_num <= din.split_table_num;
        end
        WAIT_MEM: begin
          dout_ready <= 0;
          icache_if.valid <= 1;
          icache_if.addr  <= din.pc;
        end
        WAIT_READY: begin
          icache_if.valid <= 0;
          dout_valid <= 1;
          dout.inst_raw_data <= icache_if.data;
        end
        default: begin
          $fatal(0, "gelato_inst_fetch: Invalid state");
        end
      endcase
    end
  end
endmodule
