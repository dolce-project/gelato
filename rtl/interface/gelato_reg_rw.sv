// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_macros.svh"
`include "gelato_types.svh"

interface gelato_register_update_if;
  import gelato_types::*;

  logic write[`BANK_NUM];
  reg_num_t reg_num[`BANK_NUM];
  warp_num_t warp_num[`BANK_NUM];
  warp_reg_t data[`BANK_NUM];

  // RF Arbiter -> Register bank
  modport master(output write, output reg_num, output warp_num, inout data);

  // Register bank -> RF Arbiter
  modport slave(input write, input reg_num, input warp_num, inout data);
endinterface

interface gelato_register_bank_update_if;
  import gelato_types::*;

  logic write;
  reg_num_t reg_num;
  warp_num_t warp_num;
  warp_reg_t data;

  // RF Arbiter -> Register bank
  modport master(output write, output reg_num, output warp_num, inout data);

  // Register bank -> RF Arbiter
  modport slave(input write, input reg_num, input warp_num, inout data);
endinterface

interface gelato_register_collect_request_if;
  import gelato_types::*;

  logic valid;
  logic entry_valid[`COLLECTOR_SIZE];
  warp_num_t warp_num[`COLLECTOR_SIZE];
  reg_num_t reg_num[`COLLECTOR_SIZE][`RS_INDEX];
  logic reg_valid[`COLLECTOR_SIZE][`RS_INDEX];
  bank_num_t collector_num[`COLLECTOR_SIZE]; 

  // Operand collector -> RF Arbiter
  modport master(
    inout valid,
    output entry_valid,
    output warp_num,
    output reg_num,
    output reg_valid,
    output collector_num
  );

  // RF Arbiter -> Operand collector
  modport slave(
    inout valid,
    input entry_valid,
    input warp_num,
    input reg_num,
    input reg_valid,
    input collector_num
  );
endinterface

interface gelato_register_collect_response_if;
  import gelato_types::*;

  logic valid;
  logic data_valid[`BANK_NUM];
  collector_num_t collector_index[`BANK_NUM];
  rs_num_t reg_index[`BANK_NUM];
  warp_reg_t data[`BANK_NUM];

  // RF Arbiter -> Operand collector
  modport master(
    inout valid,
    output data_valid,
    output collector_index,
    output reg_index,
    output data
  );

  // Operand collector -> RF Arbiter
  modport slave(
    inout valid,
    input data_valid,
    input collector_index,
    input reg_index,
    input data
  );
endinterface
