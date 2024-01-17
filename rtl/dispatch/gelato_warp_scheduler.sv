// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the warp scheduler of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_warp_scheduler (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_ibuffer_warpskd_if.slave buffer,
  gelato_scoreboard_warpskd_if.slave record,

  gelato_warpskd_collector_if.master issued_inst
);
  import gelato_types::*;

  typedef enum {
    SELECT_INST,
    ISSUE
  } status_t;
  status_t status;

  logic valid[`WARP_NUM];
  logic full[`WARP_NUM];
  logic conflict[`WARP_NUM];
  reg_num_t rd[`WARP_NUM];

  reg_num_t dirty_regs[`WARP_NUM][`SCOREBOARD_SIZE];

  assign dirty_regs = record.regs;

  warp_num_t last_warp;
  warp_num_t next_warp;

  generate
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_warp_valid
      // Generate full signal
      always_comb begin
        full[i] = 1;
        foreach (dirty_regs[i, j]) begin
          if (dirty_regs[i][j] == 0) begin
            full[i] = 0;
            break;
          end
        end
      end
      // Generate conflict signal
      always_comb begin
        conflict[i] = 0;
        foreach (dirty_regs[i, j]) begin
          if (buffer.valid[i] && buffer.inst[i].rd != 0 &&
              buffer.inst[i].rd == dirty_regs[i][j]) begin
            conflict[i] = 1;
            break;
          end
        end
      end
      // Generate valid signal
      assign valid[i] = buffer.valid[i] && !buffer.caught[i] &&
        (buffer.inst[i].rd == 0 || (!full[i] & !conflict[i]));
    end
  endgenerate

  always_comb begin
    warp_num_t i = last_warp + 1;
    repeat (`WARP_NUM) begin
      if (valid[i]) begin
        next_warp = i;
        break;
      end
      i++;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      last_warp <= 0;
      status <= SELECT_INST;
    end else if (rdy) begin
      case (status)
        SELECT_INST: begin
          if (!issued_inst.valid && valid[next_warp]) begin
            // Send the instruction to the collector
            issued_inst.inst  <= buffer.inst[next_warp];

            $display("Issued instruction: %h, dirty regs: %d %d %d %d",
                     buffer.inst[next_warp].pc, dirty_regs[next_warp][0],
                     dirty_regs[next_warp][1], dirty_regs[next_warp][2],
                     dirty_regs[next_warp][3]);

            // Update status
            status <= ISSUE;
          end
        end
        ISSUE: begin
          // Update scoreboard and buffer
          issued_inst.valid <= 1;
          record.new_reg <= issued_inst.inst.rd;
          record.warp_num <= next_warp;
          buffer.caught[next_warp] <= 1;

          // Update last warp number and status
          last_warp <= next_warp;
          status <= SELECT_INST;
        end
        default: begin
          $fatal(0, "gelato_warp_scheduler: Invalid status");
        end
      endcase
    end
  end
endmodule
