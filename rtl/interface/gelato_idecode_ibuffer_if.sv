// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"


interface gelato_idecode_ibuffer_if;
  import gelato_types::*;

  // Basic Information
  logic [`ADDR_INDEX] pc;
  logic [`WARP_NUM_INDEX] warp_num;
  logic [`THREAD_INDEX] thread_mask;

  // Decode instruction of the selected instruction
  gelato_inst_t inst;

  // I-Decode -> I-Buffer
  modport master(output pc, output warp_num, output thread_mask, output inst);

  // I-Buffer -> I-Decode
  modport slave(input pc, input warp_num, input thread_mask, input inst);
endinterface
