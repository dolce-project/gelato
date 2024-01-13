// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Macros for Gelato GPU.

`ifndef GELATO_MACROS_SVH
`define GELATO_MACROS_SVH

// Basic data types

`define ADDR_WIDTH 32 // 32-bit address width
`define ADDR_INDEX 31:0

`define BYTE_WIDTH 8
`define BYTE_INDEX 7:0

`define DATA_WIDTH 32 // 32-bit data width
`define DATA_INDEX 31:0

`define NUM_WIDTH 32 // 32-bit number width
`define NUM_INDEX 31:0

// Cache configuration
// L1 Cache
`define L1_CACHE_LINE_SIZE 32 // 32 B per line
`define L1_CACHE_LINE_WIDTH 5

`define L1_ICACHE_SIZE 4096 // 4 KB L1 I-Cache (direct-mapped)
`define L1_ICACHE_LINE_NUM 128 // 128 lines
`define L1_ICACHE_LINE_WIDTH 7
`define L1_ICACHE_LINE_INDEX 6:0

`define L1_DCACHE_SIZE 8192 // 8 KB L1 D-Cache (2-way set-associative)
`define L1_CACHE_LINE_INDEX 4:0
`define L1_CACHE_ADDR_WIDTH 27 // 27-bit address width
`define L1_CACHE_ADDR_INDEX 31:5
`define L1_CACHE_INDEX_WIDTH 7 // 7-bit index width
`define L1_CACHE_INDEX_INDEX 11:5
`define L1_CACHE_TAG_WIDTH 20 // 20-bit tag width
`define L1_CACHE_TAG_INDEX 31:12

`define WARP_NUM_WIDTH 2
`define WARP_NUM_INDEX 1:0
`define WARP_NUM 4
`define WARP_MAX_NUM 3
`define WARP_INDEX 3:0

`define THREAD_NUM_WIDTH 5
`define THREAD_NUM_INDEX 4:0
`define THREAD_NUM 32
`define THREAD_INDEX 31:0

`define SPLIT_TABLE_NUM_WIDTH 4
`define SPLIT_TABLE_NUM_INDEX 3:0
`define SPLIT_TABLE_NUM 16
`define SPLIT_TABLE_INDEX 15:0

`define OPCODE_WIDTH 7
`define OPCODE_INDEX 6:0

`define REG_NUM_WIDTH 5
`define REG_NUM_INDEX 4:0

`define FUNCT3_WIDTH 3
`define FUNCT3_INDEX 2:0
`define FUNCT7_WIDTH 7
`define FUNCT7_INDEX 6:0

`endif
