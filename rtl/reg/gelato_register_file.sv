// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the register file of the Gelato GPU.

module gelato_register_file (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_warpskd_collector_if.slave issued_inst,
  gelato_exec_inst_if.master exec_mem_inst,
  gelato_exec_inst_if.master exec_compute_inst,
  gelato_exec_inst_if.master exec_tensor_inst
);

  gelato_register_collect_request_if request;
  gelato_register_collect_response_if response;
  gelato_register_update_if update;

  gelato_operand_collector operand_collector (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .issued_inst(issued_inst),
    .request(request),
    .response(response),
    .exec_mem_inst(exec_mem_inst),
    .exec_compute_inst(exec_compute_inst),
    .exec_tensor_inst(exec_tensor_inst)
  );

  gelato_register_file_arbiter arbiter (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .update(update),
    .request(request),
    .response(response)
  );

  gelato_register_bank_update_if bank_update[`BANK_NUM];

  generate;
    for (genvar i = 0; i < `BANK_NUM; i++) begin : gen_register_bank
      assign bank_update[i].write = update.write[i];
      assign bank_update[i].reg_num = update.reg_num[i];
      assign bank_update[i].warp_num = update.warp_num[i];
      assign bank_update[i].read_data = update.data[i];

      gelato_register_bank register_bank (
        .clk(clk),
        .rst_n(rst_n),
        .rdy(rdy),
        .update(bank_update[i])
      );
    end
  endgenerate
endmodule
