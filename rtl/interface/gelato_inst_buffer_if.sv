// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_inst_buffer_if;
  import gelato_types::*;

  logic pop_enabled;
  logic full;
  logic empty;
  inst_t tail_data;

  // Warp Instruction Buffer -> Instruction Buffer
  modport master(inout pop_enabled, output full, output empty, output tail_data);

  // Instruction Buffer -> Warp Instruction Buffer
  modport slave(inout pop_enabled, input full, input empty, input tail_data);
endinterface
