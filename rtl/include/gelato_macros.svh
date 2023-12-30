// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Macros for Gelato GPU.

`ifndef GELATO_MACROS_SVH
`define GELATO_MACROS_SVH

`define ADDR_WIDTH 32 // 32-bit address width
`define ADDR_INDEX 31:0

`define NUM_WIDTH 32 // 32-bit number width
`define NUM_INDEX 31:0

`define WARP_NUM_WIDTH 2
`define WARP_NUM_INDEX 1:0
`define WARP_NUM 4
`define WARP_INDEX 3:0

`define THREAD_NUM_WIDTH 5
`define THREAD_NUM_INDEX 4:0
`define THREAD_NUM 32
`define THREAD_INDEX 31:0

`define OPCODE_WIDTH 7
`define OPCODE_INDEX 6:0

`define REG_NUM_WIDTH 5
`define REG_NUM_INDEX 4:0

`define FUNCT3_WIDTH 3
`define FUNCT3_INDEX 2:0
`define FUNCT7_WIDTH 7
`define FUNCT7_INDEX 6:0

`endif
