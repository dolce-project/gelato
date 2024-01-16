// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_warpskd_collector_if;
  import gelato_types::*;

  logic valid;
  logic caught;
  inst_t inst;

  // Warp Scheduler -> Operand Collector
  modport master(output valid, inout caught, output inst);

  // Operand Collector -> Warp Scheduler
  modport slave(input valid, inout caught, input inst);
endinterface
