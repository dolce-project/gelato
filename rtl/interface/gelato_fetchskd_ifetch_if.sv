// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_fetchskd_ifetch_if;
  import gelato_types::*;

  // Reday State
  logic caught;

  // Information of the selected program counter
  logic valid;
  addr_t pc;
  warp_num_t warp_num;
  split_table_num_t split_table_num;

  // Fetch Scheduler -> I-Fetch
  modport master(inout caught, output valid, output pc, output warp_num, output split_table_num);

  // I-Fetch -> Fetch Scheduler
  modport slave(inout caught, input valid, input pc, input warp_num, input split_table_num);

endinterface

