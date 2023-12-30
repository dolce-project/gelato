// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction unit of the Gelato GPU.

module gelato_inst_unit (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_pctable_ifetch_if.slave selected_pc,
  gelato_ifetch_ibuffer_if.master decoded_inst
);

  gelato_inst_fetch inst_fetch (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),

    .selected_pc(selected_pc)
  );
endmodule
