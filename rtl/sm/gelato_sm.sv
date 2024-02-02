// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Streaming Multiprocessor of Gelato GPU

module gelato_sm (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_init_sm_if.slave init_sm,
  gelato_l2_cache_if.slave inst_cache_request,
  gelato_l2_cache_if.slave data_cache_request
);
  gelato_init_warp_if init;
  gelato_idecode_ibuffer_if inst_decoded_data;
  gelato_ibuffer_fetchskd_if buffer_status;

  gelato_fetch fetch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .init(init),
    .inst_decoded_data(inst_decoded_data),
    .fetch_data(inst_cache_request),
    .buffer_status(buffer_status)
  );

  gelato_warpskd_collector_if issued_inst;

  gelato_dispatch dispatch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .inst_decoded_data(inst_decoded_data),
    .issued_inst(issued_inst),
    .buffer_status(buffer_status),
    .reg_wb(selected_reg_wb)
  );

  gelato_exec_inst_if exec_compute_inst;
  gelato_exec_inst_if exec_mem_inst;
  gelato_exec_inst_if exec_tensor_inst;

  gelato_register_file register_file (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .issued_inst(issued_inst),
    .exec_compute_inst(exec_compute_inst),
    .exec_mem_inst(exec_mem_inst),
    .exec_tensor_inst(exec_tensor_inst),
    .reg_wb(selected_reg_wb)
  );

  gelato_reg_wb_if selected_reg_wb;
  gelato_reg_wb_if reg_wb[3];

  gelato_compute compute_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .exec_inst(exec_compute_inst),
    .reg_wb(reg_wb[0])
  );

  gelato_load_store load_store_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .exec_inst(exec_mem_inst),
    .mem_data(data_cache_request),
    .reg_wb(reg_wb[1])
  );

  // gelato_tensor tensor_unit (
  //   .clk(clk),
  //   .rst_n(rst_n),
  //   .rdy(rdy),
  //   .exec_inst(exec_tensor_inst),
  //   .reg_wb(reg_wb[2])
  // );
endmodule
