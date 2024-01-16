// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the dispatch unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_dispatch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_idecode_ibuffer_if.slave inst_decoded_data,
  gelato_warpskd_collector_if.master inst_out
);
  
endmodule
