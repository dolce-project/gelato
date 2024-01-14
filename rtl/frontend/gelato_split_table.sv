// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the split table of the Gelato GPU. Split table is the key module in a SIMT execution model. 

module gelato_split_table (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_pctable_fetchskd_if.master pc_table,
  gelato_idecode_split_if.slave split_data
);

endmodule
