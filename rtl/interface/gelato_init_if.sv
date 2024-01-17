// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_init_if;
  import gelato_types::*;

  logic valid;
  addr_t pc;
  integer workers;

  // GPU -> split table
  modport master(output valid, output pc, output workers);

  // split table -> GPU
  modport slave(input valid, input pc, input workers);
endinterface
