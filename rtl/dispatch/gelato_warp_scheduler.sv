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

  gelato_warpskd_collector_if.master inst_out
);
  import gelato_pkg::*;

  typedef enum {
    SELECT_INST,
    WAIT_CAUGHT
  } status_t;
  status_t status;

  logic valid[`WARP_NUM];
  logic full[`WARP_NUM];
  logic conflict[`WARP_NUM];
  reg_num_t rd[`WARP_NUM];

  warp_num_t last_warp;
  warp_num_t next_warp;

  generate
    for (genvar i = 0; i < `WARP_NUM; i++) begin : gen_warp_valid
      // Generate full signal
      always_comb begin
        integer j = 0;
        full[i] = 1;
        repeat (`SCOREBOARD_SIZE) begin
          if (record.regs[i][j++] == 0) begin
            full[i] = 0;
            break;
          end
        end
      end
      // Generate conflict signal
      always_comb begin
        integer j = 0;
        conflict[i] = 0;
        repeat (`SCOREBOARD_SIZE) begin
          if (buffer.valid[i] && buffer.inst[i].rd != 0 && buffer.inst[i].rd == record.regs[i][
            j++
            ]) begin
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
    end else if (rdy) begin
      case (status)
        SELECT_INST: begin
          if (valid[next_warp]) begin
            // Send the instruction to the collector
            inst_out.valid <= 1;
            inst_out.inst <= buffer.inst[next_warp];

            // Update status
            status <= WAIT_CAUGHT;
          end
        end
        WAIT_CAUGHT: begin
          if (inst_out.caught) begin
            // Update scoreboard and buffer
            record.new_reg <= inst_out.inst.rd;
            record.warp_num <= next_warp;
            buffer.caught[next_warp] <= 1;

            // Update last warp number and status
            last_warp <= next_warp;
            status <= SELECT_INST;

            // Clear output
            inst_out.caught <= 0;
            inst_out.valid <= 0;
          end
        end
        default: begin
          $fatal(0, "gelato_warp_scheduler: Invalid status");
        end
      endcase
    end
  end
endmodule
