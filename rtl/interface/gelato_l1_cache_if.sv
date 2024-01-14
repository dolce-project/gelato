// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_l1_cache_if;
  import gelato_types::*;

  // L1 Cache -> L2 Cache
  logic valid;
  l1_cache_addr_t addr;

  // L2 Cache -> L1 Cache
  logic done;
  l1_cache_line_t data;

  // L2 Cache
  modport master(input valid, input addr, output done, output data);

  // L1 Cache
  modport slave(input valid, output addr, input done, input data);
endinterface