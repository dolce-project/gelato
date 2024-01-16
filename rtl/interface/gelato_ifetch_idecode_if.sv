// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"


interface gelato_ifetch_idecode_if;
  import gelato_types::*;

  // Basic Information
  logic valid;
  addr_t pc;
  warp_num_t warp_num;
  split_table_num_t split_table_num;
  data_t inst;

  // I-Fetch -> I-Decode
  modport master(inout valid, output pc, output warp_num, output split_table_num, output inst);

  // I-Decode -> I-Fetch
  modport slave(inout valid, input pc, input warp_num, input split_table_num, input inst);
endinterface
