// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"


interface gelato_idecode_ibuffer_if;
  import gelato_types::*;

  // Basic Information
  logic valid;
  addr_t pc;
  warp_num_t warp_num;
  thread_mask_t thread_mask;

  // Decode instruction of the selected instruction
  inst_t inst;

  // I-Decode -> I-Buffer
  modport master(output valid, output pc, output warp_num, output thread_mask, output inst);

  // I-Buffer -> I-Decode
  modport slave(input valid, input pc, input warp_num, input thread_mask, input inst);
endinterface
