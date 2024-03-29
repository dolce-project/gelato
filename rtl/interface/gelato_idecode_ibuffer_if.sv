// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"


interface gelato_idecode_ibuffer_if;
  import gelato_types::*;

  // Basic Information
  logic valid;

  // Decode instruction of the selected instruction
  inst_t inst;

  // I-Decode -> I-Buffer
  modport master(output valid, output inst);

  // I-Buffer -> I-Decode
  modport slave(input valid, input inst);
endinterface
