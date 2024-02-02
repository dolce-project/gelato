// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_init_sm_if;
  import gelato_types::*;

  logic valid;
  addr_t pc;
  int3_t gridDim;
  int3_t blockDim;
  int3_t blockIdx;

  // GPU -> SM Controller
  modport master(output valid, output pc, output gridDim, output blockDim, output blockIdx);

  // SM Controller -> GPU
  modport slave(input valid, input pc, input gridDim, input blockDim, input blockIdx);
endinterface

interface gelato_init_warp_if;
  import gelato_types::*;

  logic valid;
  addr_t pc;
  int3_t gridDim;
  int3_t blockDim;
  int3_t blockIdx;
  integer workers;

  // SM Controller -> Split Table
  modport master_split_table(output valid, output pc, output workers);

  // Split Table -> SM Controller
  modport slave_split_table(input valid, input pc, input workers);

  // SM Controller -> RF Arbiter
  modport master_rf_arbiter(output valid, output gridDim, output blockDim, output blockIdx);

  // RF Arbiter -> SM Controller
  modport slave_rf_arbiter(input valid, input gridDim, input blockDim, input blockIdx);
endinterface
