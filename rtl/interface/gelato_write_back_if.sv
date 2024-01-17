// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_reg_wb_if;
  import gelato_types::*;

  logic valid;
  logic caught; // caught by scoreboard
  reg_num_t reg_num;
  warp_num_t warp_num;
  thread_mask_t thread_mask;
  warp_reg_t data;

  // Execute -> RF Arbiter
  modport master(
    inout valid,
    inout caught,
    output reg_num,
    output warp_num,
    output thread_mask,
    output data
  );

  // RF Arbiter -> Execute
  modport slave(
    inout valid,
    inout caught,
    input reg_num,
    input warp_num,
    input thread_mask,
    inout data
  );
endinterface

// interface gelato_split_table_wb_if;
  
// endinterface
