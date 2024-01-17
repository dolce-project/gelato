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

  typedef logic [`OPCODE_INDEX] opcode_t;

  typedef logic [`REG_NUM_INDEX] reg_num_t;

  typedef logic [`L1_CACHE_ADDR_INDEX] l1_cache_addr_t;

  typedef logic [`L1_CACHE_INDEX_INDEX] l1_cache_index_t;

  typedef logic [`L1_CACHE_TAG_INDEX] l1_cache_tag_t;

  typedef logic [`L1_CACHE_OFFSET_INDEX] l1_cache_offset_t;

  typedef logic [`L1_CACHE_LINE_SIZE-1:0] l1_cache_line_t;

  typedef logic [`WARP_NUM_INDEX] warp_num_t;

  typedef logic [`THREAD_NUM_INDEX] thread_num_t;

  typedef logic [`THREAD_INDEX] thread_mask_t;

  typedef logic [`SPLIT_TABLE_NUM_INDEX] split_table_num_t;

  typedef logic [`BANK_NUM_INDEX] bank_num_t;

  typedef logic [`COLLECTOR_NUM_INDEX] collector_num_t;

  typedef logic [`RS_NUM_INDEX] rs_num_t;

  typedef logic [(`THREAD_NUM*`DATA_WIDTH-1):0] warp_reg_t;

  typedef struct packed {
    opcode_t opcode;

    reg_num_t rd;
    reg_num_t rs1;
    reg_num_t rs2;
    reg_num_t rs3;

    num_t imm;

    logic [`FUNCT3_INDEX] funct3;
    logic [`FUNCT7_INDEX] funct7;

    addr_t pc;
    warp_num_t warp_num;
    thread_mask_t thread_mask;
  } inst_t;

  typedef struct packed {
    logic valid;
    logic active;
    addr_t current_pc;
    addr_t reconv_pc;
    split_table_num_t reconv_table_num;
    thread_mask_t thread_mask;
    thread_mask_t arrived_mask;
  } split_table_entry_t;

  typedef struct packed {
    logic valid;
    l1_cache_tag_t tag;
    l1_cache_line_t data;
  } l1_cache_entry_t;

  typedef struct packed {
    logic valid;
    inst_t inst;
  } inst_buffer_entry_t;

  typedef struct {
    logic valid;
    logic ready;
    inst_t inst;
    
    reg_num_t [`RS_INDEX] rs;
    warp_reg_t [`RS_INDEX] rs_data;
    logic [`RS_INDEX] rs_valid;
  } collector_entry_t;
endpackage

`endif
