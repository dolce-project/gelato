// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_l1_cache_if;
  import gelato_types::*;

  // I-Fetch / Load Store Buffer -> I-Cache / D-Cache
  logic valid;
  addr_t addr;

  // I-Cache / D-Cache -> I-Fetch / Load Store Buffer
  logic done;
  data_t data;

  // I-Cache
  modport master(input valid, input addr, output done, output data);

  // I-Fetch
  modport slave(output valid, output addr, input done, input data);
endinterface
