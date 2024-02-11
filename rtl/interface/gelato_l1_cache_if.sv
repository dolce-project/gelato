// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

import gelato_types::*;

interface gelato_l1_icache_if;
  // I-Fetch -> I-Cache
  logic  valid;
  addr_t addr;

  // I-Cache -> I-Fetch
  logic  ready;
  data_t data;

  // I-Fetch
  modport master(output valid, output addr, input ready, input data);

  // I-Cache
  modport slave(input valid, input addr, output ready, output data);
endinterface
