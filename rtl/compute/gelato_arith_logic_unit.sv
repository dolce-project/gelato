// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the arithmetic logic unit (ALU) of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_arith_logic_unit (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_alu_task_if.slave compute_task
);
  import gelato_types::*;

  typedef enum { IDLE } status_t;
  status_t status;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      compute_task.done <= 0;
    end else begin
      case (status)
        IDLE: begin
          if (compute_task.valid && !compute_task.done) begin
            case (compute_task.op)
              ADD: begin
                compute_task.rd <= compute_task.rs1 + compute_task.rs2;
                compute_task.done <= 1;
              end
              default: begin
                $fatal(0, "ALU: Invalid operation");
              end
            endcase
          end
        end
        default: begin
          $fatal(0, "ALU: Invalid status");
        end
      endcase
    end
  end
endmodule
