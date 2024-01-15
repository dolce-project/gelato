// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_idecode_split_if;
  import gelato_types::*;

  // Get thread mask (returned by combinational logic)
  warp_num_t warp_num;
  split_table_num_t split_table_num;
  thread_mask_t thread_mask;

  // Basic Information
  logic valid;
  logic stall;
  addr_t updated_pc;

  // I-Decode -> Split Table
  modport master(
    output warp_num,
    output split_table_num,
    input thread_mask,
    output valid,
    output stall,
    output updated_pc
  );

  // Split Table -> I-Decode
  modport slave(
    input warp_num,
    input split_table_num,
    output thread_mask,
    input valid,
    input stall,
    input updated_pc
  );
endinterface
