// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Top module of the Gelato GPU

module gelato (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_init_if.slave init,
  gelato_ram_if.slave ram
);
  gelato_idecode_ibuffer_if inst_decoded_data;

  gelato_fetch fetch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .init(init),
    .inst_decoded_data(inst_decoded_data),
    .fetch_data(ram)
  );

  gelato_warpskd_collector_if issued_inst;

  gelato_dispatch dispatch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .inst_decoded_data(inst_decoded_data),
    .issued_inst(issued_inst)
  );

  gelato_issue_inst_if issued_mem_inst;
  gelato_issue_inst_if issued_compute_inst;
  gelato_issue_inst_if issued_tensor_inst;

  gelato_register_file register_file (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .issued_inst(issued_inst),
    .issued_mem_inst(issued_mem_inst),
    .issued_compute_inst(issued_compute_inst),
    .issued_tensor_inst(issued_tensor_inst)
  );
endmodule
