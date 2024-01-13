// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.sv"

interface gelato_pctable_ifetch_if;
  import gelato_types::*;

  logic valid[`WARP_NUM];
  addr_t pc[`WARP_NUM];
  split_table_num_t split_table_num[`WARP_NUM];

  // PC Table -> I-Fetch
  modport master(output valid, output pc, output split_table_num);

  // I-Fetch -> PC Table
  modport slave(input valid, input pc, input split_table_num);
endinterface
