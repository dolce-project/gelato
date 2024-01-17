// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_ibuffer_warpskd_if;
  import gelato_types::*;

  logic  valid [`WARP_NUM];
  logic  caught[`WARP_NUM];
  inst_t inst  [`WARP_NUM];

  // I-Buffer -> Warp Scheduler
  modport master(output valid, inout caught, output inst);

  // Warp Scheduler -> I-Buffer
  modport slave(input valid, inout caught, input inst);
endinterface

interface gelato_scoreboard_warpskd_if;
  import gelato_types::*;

  reg_num_t new_reg;
  warp_num_t warp_num;
  reg_num_t regs[`WARP_NUM][`SCOREBOARD_SIZE];

  // Scoreboard -> Warp Scheduler
  modport master(inout new_reg, input warp_num, output regs);

  // Warp Scheduler -> Scoreboard
  modport slave(inout new_reg, output warp_num, input regs);
endinterface
