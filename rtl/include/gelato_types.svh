// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Type definitions for Gelato GPU.

`ifndef GELATO_TYPES_SVH
`define GELATO_TYPES_SVH

`include "gelato_macros.svh"

package gelato_types;

  typedef logic [`ADDR_INDEX] addr_t;

  typedef logic [`DATA_INDEX] data_t;

  typedef logic [`NUM_INDEX] num_t;

  typedef logic [`L1_CACHE_ADDR_INDEX] l1_cache_addr_t;

  typedef logic [`L1_CACHE_LINE_SIZE-1:0] l1_cache_line_t;

  typedef logic [`WARP_NUM_INDEX] warp_num_t;

  typedef logic [`THREAD_NUM_INDEX] thread_num_t;

  typedef logic [`SPLIT_TABLE_NUM_INDEX] split_table_num_t;

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
