// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the compute unit scheduler of the Gelato GPU.


`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_compute_scheduler (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_exec_inst_if.slave exec_inst,
  gelato_compute_task_if.master compute_task,
  gelato_reg_wb_if.master reg_wb
);
  import gelato_types::*;

  typedef enum {
    IDLE,
    WAIT_COMPUTE
  } status_t;

  status_t status;

  always_comb begin
    if (exec_inst.valid) begin
      case (exec_inst.inst.opcode)
        `OPCODE_ARITHI: begin
          compute_task.rs1 = exec_inst.src1;
          compute_task.rs2 = {`THREAD_NUM{exec_inst.inst.imm}};
          case (exec_inst.inst.funct3)
            `FUNCT3_ADDI: begin
              compute_task.op = ADD;
            end
            default: begin
              $fatal(0, "CU: Invalid funct3");
            end
          endcase
        end
        default: begin
          $fatal(0, "CU: Invalid opcode");
        end
      endcase
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      compute_task.valid <= 0;
    end else begin
      case (status)
        IDLE: begin
          if (exec_inst.valid) begin
            compute_task.valid <= 1;
            exec_inst.valid <= 0;
            status <= WAIT_COMPUTE;
          end
        end
        WAIT_COMPUTE: begin
        end
        default: begin
          $fatal(0, "CU: Invalid status");
        end
      endcase
    end
  end
endmodule
