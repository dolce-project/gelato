// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_ram_if;
  import gelato_types::*;

  // Core -> Memory
  logic valid;
  logic write;
  addr_t addr;

  // Memory -> Core
  logic done;
  data_t data;

  // Core
  modport master(output valid, output write, output addr, input done, input data);

  // Memory
  modport slave(input valid, input write, input addr, output done, output data);
endinterface
