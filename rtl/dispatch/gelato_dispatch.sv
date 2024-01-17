// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the dispatch unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_dispatch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_idecode_ibuffer_if.slave inst_decoded_data,
  gelato_warpskd_collector_if.master issued_inst,
  gelato_ibuffer_fetchskd_if.master buffer_status,
  gelato_reg_wb_if.slave reg_wb
);
  gelato_ibuffer_warpskd_if buffer;
  gelato_scoreboard_warpskd_if record;

  gelato_inst_buffer inst_buffer (
    .clk  (clk),
    .rst_n(rst_n),
    .rdy  (rdy),

    .buffer_status(buffer_status),
    .inst_decoded_data(inst_decoded_data),
    .buffer(buffer)
  );

  gelato_scoreboard scoreboard (
    .clk  (clk),
    .rst_n(rst_n),
    .rdy  (rdy),

    .record(record),
    .reg_wb(reg_wb)
  );

  gelato_warp_scheduler warp_scheduler (
    .clk  (clk),
    .rst_n(rst_n),
    .rdy  (rdy),

    .buffer(buffer),
    .record(record),

    .issued_inst(issued_inst)
  );
endmodule
