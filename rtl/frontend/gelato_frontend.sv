// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the frontend of the Gelato GPU.

module gelato_frontend (
  input logic clk,
  input logic rst_n,
  input logic rdy
);
  gelato_fetchskd_ifetch_if inst_pc;
  gelato_mem_if inst_cache_request;
  gelato_ifetch_idecode_if inst_raw_data;

  gelato_inst_fetch inst_fetch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .inst_pc(inst_pc),
    .inst_cache_request(inst_cache_request),
    .inst_raw_data(inst_raw_data)
  );

  gelato_inst_cache inst_cache (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .inst_cache_request(inst_cache_request)
  );

  gelato_pctable_fetchskd_if pc_table;

  gelato_fetch_scheduler fetch_scheduler (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .pc_table(pc_table),
    .inst_pc(inst_pc)
  );

  gelato_split_table split_table (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .pc_table(pc_table)
  );
endmodule
