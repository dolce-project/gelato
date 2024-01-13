// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction cache of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_inst_cache (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // From the instruction fetch unit
  gelato_mem_if.master inst_cache_request

  // To L2 Cache
  // gelato_l1_cache_if.master fetch_data
);
  import gelato_types::*;

  logic hit;
  l1_cache_line_t cache_lines[`L1_ICACHE_LINE_NUM];


endmodule
