// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_compute_task_if;
  import gelato_types::*;

  arith_oper_t op;

  logic valid;
  warp_reg_t rs1;
  warp_reg_t rs2;
  warp_reg_t rs3;

  logic done;
  warp_reg_t rd;

  // CU -> ALU
  modport master(
    output op,
    output valid,
    output rs1,
    output rs2,
    output rs3,
    input done,
    input rd
  );
endinterface

interface gelato_alu_task_if;
  import gelato_types::*;

  arith_oper_t op;

  logic valid;
  data_t rs1;
  data_t rs2;
  data_t rs3;

  logic done;
  data_t rd;

  // ALU -> CU
  modport slave(
    input op,
    input valid,
    input rs1,
    input rs2,
    input rs3,
    output done,
    output rd
  );
endinterface
