// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_reg_wb_if;
  import gelato_types::*;

  logic valid;
  reg_num_t rd;
  warp_num_t warp_num;
  thread_mask_t thread_mask;
  warp_reg_t data;

  // Execute -> RF Arbiter
  modport master(
    inout valid,
    output rd,
    output warp_num,
    output thread_mask,
    output data
  );

  // RF Arbiter -> Execute
  modport slave(
    inout valid,
    input rd,
    input warp_num,
    input thread_mask,
    inout data
  );
endinterface

// interface gelato_split_table_wb_if;
  
// endinterface
