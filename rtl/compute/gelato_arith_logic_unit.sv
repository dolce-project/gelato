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

  typedef enum {
    IDLE,
    MUL,
    MULS,
    MULSU
  } status_t;
  status_t status;

  integer multiply_stage;
  logic [2*`DATA_WIDTH-1:0] multiply_result;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      compute_task.done <= 0;
    end else begin
      case (status)
        IDLE: begin
          if (compute_task.valid && !compute_task.done) begin
            case (compute_task.op)
              ADD: begin
                compute_task.rd   <= compute_task.rs1 + compute_task.rs2;
                compute_task.done <= 1;
              end
              SUB: begin
                compute_task.rd   <= compute_task.rs1 - compute_task.rs2;
                compute_task.done <= 1;
              end
              SLL: begin
                compute_task.rd   <= compute_task.rs1 << compute_task.rs2;
                compute_task.done <= 1;
              end
              SRL: begin
                compute_task.rd   <= {compute_task.rs1[31], compute_task.rs1[30:0] >> compute_task.rs2};
                compute_task.done <= 1;
              end
              SRA: begin
                compute_task.rd   <= compute_task.rs1 >>> compute_task.rs2;
                compute_task.done <= 1;
              end
              XOR: begin
                compute_task.rd   <= compute_task.rs1 ^ compute_task.rs2;
                compute_task.done <= 1;
              end
              MUL:
              MULHU: begin
                status <= MUL;
                multiply_result <= 0;
                multiply_stage <= 0;
              end
              MULH: begin
                status <= MULS;
                multiply_result <= 0;
                multiply_stage <= 0;
              end
              LT: begin
                if (compute_task.rs1[31] == compute_task.rs2[31]) begin
                  compute_task.rd   <= {{31{1'b0}}, compute_task.rs1[30:0] < compute_task.rs2[30:0]};
                end else begin
                  compute_task.rd   <= {{31{1'b0}}, compute_task.rs1[31]};
                end
                compute_task.done <= 1;
              end
              LTU: begin
                compute_task.rd   <= {{31{1'b0}}, compute_task.rs1 < compute_task.rs2};
                compute_task.done <= 1;
              end
              default: begin
                $fatal(0, "ALU: Invalid operation");
              end
            endcase
          end
        end
        MUL: begin
          case (multiply_stage)
            0: begin
              multiply_result <= multiply_result + compute_task.rs1[15:0] * compute_task.rs2[15:0];
              multiply_stage <= multiply_stage + 1;
            end
            1: begin
              multiply_result <= multiply_result + compute_task.rs1[31:16] * compute_task.rs2[15:0] << 16;
              multiply_stage <= multiply_stage + 1;
            end
            2: begin
              multiply_result <= multiply_result + compute_task.rs1[15:0] * compute_task.rs2[31:16] << 16;
              multiply_stage <= multiply_stage + 1;
            end
            3: begin
              multiply_result <= multiply_result + compute_task.rs1[31:16] * compute_task.rs2[31:16] << 32;
              multiply_stage <= multiply_stage + 1;
            end
            4: begin
              compute_task.rd <= compute_task.op == MUL ? multiply_result[31:0] : multiply_result[63:32];
              compute_task.done <= 1;
              status <= IDLE;
            end
            default: begin
              $fatal(0, "ALU: Invalid multiply stage");
            end
          endcase
        end
        MULS: begin
          case (multiply_stage)
            0: begin
              multiply_result <= multiply_result + compute_task.rs1[15:0] * compute_task.rs2[15:0];
              multiply_stage <= multiply_stage + 1;
            end
            1: begin
              multiply_result <= multiply_result + {1'b0, compute_task.rs1[30:16]} * compute_task.rs2[15:0] << 16;
              multiply_stage <= multiply_stage + 1;
            end
            2: begin
              multiply_result <= multiply_result + compute_task.rs1[15:0] * compute_task.rs2[31:16] << 16;
              multiply_stage <= multiply_stage + 1;
            end
            3: begin
              multiply_result <= multiply_result + {1'b0, compute_task.rs1[30:16]} * {1'b0, compute_task.rs2[30:16]} << 32;
              multiply_stage <= multiply_stage + 1;
            end
            4: begin
              multiply_result[63] <= compute_task.rs1[31] ^ compute_task.rs2[31];
              multiply_stage <= multiply_stage + 1;
            end
            5: begin
              compute_task.rd <= multiply_result[63:32];
              compute_task.done <= 1;
              status <= IDLE;
            end
            default: begin
              $fatal(0, "ALU: Invalid multiply stage");
            end
          endcase
        end
        MULSU: begin
          // TODO
        end
        default: begin
          $fatal(0, "ALU: Invalid status");
        end
      endcase
    end
  end
endmodule
