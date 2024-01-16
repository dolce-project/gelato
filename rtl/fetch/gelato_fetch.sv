// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the fetch unit of the Gelato GPU.

module gelato_fetch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_init_if.slave init,
  gelato_ram_if.slave fetch_data
);
  gelato_fetchskd_ifetch_if inst_pc;
  gelato_l1_cache_if inst_cache_request;
  gelato_ifetch_idecode_if inst_raw_data;

  gelato_inst_fetch inst_fetch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .inst_pc(inst_pc),
    .inst_cache_request(inst_cache_request),
    .inst_raw_data(inst_raw_data)
  );

  gelato_idecode_split_if split_data;
  gelato_idecode_ibuffer_if inst_decoded_data;

  gelato_inst_decode inst_decode_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .inst_raw_data(inst_raw_data),
    .split_data(split_data),
    .inst_decoded_data(inst_decoded_data)
  );

  gelato_l1_inst_cache inst_cache (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .inst_cache_request(inst_cache_request),
    .fetch_data(fetch_data)
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

    .init(init),

    .pc_table(pc_table),
    .split_data(split_data)
  );
endmodule
