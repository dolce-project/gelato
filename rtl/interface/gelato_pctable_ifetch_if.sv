// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"

interface gelato_pctable_ifetch_if;
  // Information of the selected program counter
  logic [`ADDR_INDEX] pc;
  logic [`WARP_NUM_INDEX] warp_num;
  logic [`THREAD_NUM_INDEX] thread_mask;

  // PC Table
  modport master(output pc, output warp_num, output thread_mask);

  // Instruction Fetch Unit
  modport slave(input pc, input warp_num, input thread_mask);

endinterface

