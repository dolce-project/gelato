// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the tensor unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_tensor (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_exec_inst_if.slave exec_inst,
  gelato_reg_wb_if.master   reg_wb
);
  import gelato_types::*;

  typedef enum {
    IDLE,
    MUL1,
    MUL2,
    MUL3,
    MUL4,
    ADD
  } status_t;
  status_t status;

  logic [2:0] multiply_stage;
  data_t rs1[4][8], rs2[4][8], rs3[4][8], rd[4][8];
  data_t multiply_a[2][4], multiply_b[4][4], multiply_c[2][4];
  logic [63:0] multiply_result[2][4][4];
  data_t multiply_d[2][4];
  logic multiply_mask[4][8];

  data_t result[`THREAD_NUM];
  thread_mask_t thread_mask;

  data_t wb_reg[`THREAD_NUM];

  assign multiply_stage = exec_inst.inst.funct3;

  generate
    for (genvar i = 0; i < 4; i++) begin : gen_tensor_row
      for (genvar j = 0; j < 8; j++) begin : gen_tensor_column
        assign rs1[i][j] = exec_inst.rs1[(i*8+j+1)*`DATA_WIDTH-1:(i*8+j)*`DATA_WIDTH];
        assign rs2[i][j] = exec_inst.rs2[(i*8+j+1)*`DATA_WIDTH-1:(i*8+j)*`DATA_WIDTH];
        assign rs3[i][j] = exec_inst.rs3[(i*8+j+1)*`DATA_WIDTH-1:(i*8+j)*`DATA_WIDTH];
        assign result[i*8+j] = rd[i][j];
        assign thread_mask[i*8+j] = multiply_mask[i][j];
      end
    end

    for (genvar i = 0; i < 2; i++) begin : gen_a_row
      for (genvar j = 0; j < 4; j++) begin : gen_a_column
        assign multiply_a[i][j] = rs1[i[1:0]+{multiply_stage[0],1'b0}][j[2:0]+{multiply_stage[2],2'b0}];
      end
    end

    for (genvar i = 0; i < 4; i++) begin : gen_b_row
      for (genvar j = 0; j < 4; j++) begin : gen_b_column
        assign multiply_b[i][j] = rs2[i][j[2:0]+{multiply_stage[1], 2'b0}];
      end
    end

    for (genvar i = 0; i < 2; i++) begin : gen_c_row
      for (genvar j = 0; j < 4; j++) begin : gen_c_column
        assign multiply_c[i][j] = rs3[i[1:0]+{multiply_stage[0],1'b0}][j[2:0]+{multiply_stage[1],2'b0}];
        assign rd[i[1:0]+{multiply_stage[0],1'b0}][j[1:0]+{multiply_stage[1],2'b0}] = multiply_d[i][j];
      end
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status <= IDLE;
    end else begin
      case (status)
        IDLE: begin
          if (rdy) begin
            for (int i = 0; i < 4; i++) begin
              for (int j = 0; j < 8; j++) begin
                case (multiply_stage[1:0])
                  0: multiply_mask[i][j] <= (i < 2) & (j < 4);
                  1: multiply_mask[i][j] <= (i >= 2) & (j < 4);
                  2: multiply_mask[i][j] <= (i < 2) & (j >= 4);
                  3: multiply_mask[i][j] <= (i >= 2) & (j >= 4);
                  default: $fatal(0, "Tensor: Invalid multiply_stage");
                endcase
              end
            end
            status <= MUL1;
          end
        end
        MUL1: begin
          for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
              for (int k = 0; k < 4; k++) begin
                multiply_result[i][j][k] <= multiply_a[i][k][15:0] * multiply_b[k][j][15:0];
              end
            end
          end
          status <= MUL2;
        end
        MUL2: begin
          for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
              for (int k = 0; k < 4; k++) begin
                multiply_result[i][j][k] <= multiply_result[i][j][k] + multiply_a[i][k][31:16] * multiply_b[k][j][15:0] << 16;
              end
            end
          end
          status <= MUL3;
        end
        MUL3: begin
          for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
              for (int k = 0; k < 4; k++) begin
                multiply_result[i][j][k] <= multiply_result[i][j][k] + multiply_a[i][k][15:0] * multiply_b[k][j][31:16] << 16;
              end
            end
          end
          status <= MUL4;
        end
        MUL4: begin
          for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
              for (int k = 0; k < 4; k++) begin
                multiply_result[i][j][k] <= multiply_result[i][j][k] + multiply_a[i][k][31:16] * multiply_b[k][j][31:16] << 32;
              end
            end
          end
          status <= ADD;
        end
        ADD: begin
          for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 4; j++) begin
              multiply_d[i][j] <= multiply_c[i][j] + multiply_result[i][0][j] + multiply_result[i][1][j] + multiply_result[i][2][j] + multiply_result[i][3][j];
            end
          end
          status <= IDLE;
        end
        default: $fatal(0, "Tensor: Invalid status");
      endcase
    end
  end

endmodule
