// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction fetch unit of the Gelato GPU.

module gelato_inst_fetch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_pctable_ifetch_if.slave selected_pc
);
  typedef enum { IDLE } status_t;

  status_t status;
endmodule
