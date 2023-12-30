// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Type definitions for Gelato GPU.

`ifndef GELATO_TYPES_SVH
`define GELATO_TYPES_SVH

`include "gelato_macros.svh"

package gelato_types;
  typedef struct packed {
    logic [`OPCODE_INDEX] opcode;
    logic [`REG_NUM_INDEX] rd;
    logic [`REG_NUM_INDEX] rs1;
    logic [`REG_NUM_INDEX] rs2;
    logic [`REG_NUM_INDEX] rs3;
    logic [`NUM_INDEX] imm;
    logic [`FUNCT3_INDEX] funct3;
    logic [`FUNCT7_INDEX] funct7;
  } gelato_inst_t;
endpackage

`endif
