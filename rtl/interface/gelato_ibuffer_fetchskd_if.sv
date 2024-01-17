// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_ibuffer_fetchskd_if;
  import gelato_types::*;

  logic available[`WARP_NUM];

  // I-Buffer -> Fetch Scheduler
  modport master(output available);

  // Fetch Scheduler -> I-Buffer
  modport slave(input available);
endinterface
