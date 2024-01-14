// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_mem_if;
  import gelato_types::*;

  // Core -> Memory
  logic valid;
  addr_t addr;

  // Memory -> Core
  logic done;
  data_t data;

  // Memory
  modport master(input valid, input addr, output done, output data);

  // Core
  modport slave(output valid, output addr, input done, input data);
endinterface
