// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the compute unit (CU) of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_compute (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_exec_inst_if.slave exec_inst,
  gelato_reg_wb_if.master reg_wb
);
  import gelato_types::*;

  gelato_compute_task_if compute_task;
  gelato_alu_task_if alu_task[`THREAD_NUM];

  gelato_compute_scheduler compute_scheduler (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .exec_inst(exec_inst),
    .compute_task(compute_task),
    .reg_wb(reg_wb)
  );

  generate
    for (genvar i = 0; i < `THREAD_NUM; i++) begin : gen_alu
      assign alu_task[i].valid = compute_task.valid;
      assign alu_task[i].op = compute_task.op;
      assign alu_task[i].rs1 = compute_task.rs1[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH];
      assign alu_task[i].rs2 = compute_task.rs2[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH];
      assign compute_task.rd[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH] = alu_task[i].rd;
      assign compute_task.done = alu_task[i].done;

      gelato_arith_logic_unit alu (
        .clk(clk),
        .rst_n(rst_n),
        .rdy(rdy),
        .compute_task(alu_task[i])
      );
    end
  endgenerate
endmodule
