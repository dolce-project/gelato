// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// RAM of the Gelato GPU (for test only)

`include "gelato_types.svh"

module fake_ram (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_ram_if.slave ram
);
  byte mem[`RAM_SIZE];

  always_comb begin
    ram.done = 1'b1;
    ram.data = { mem[ram.addr + 3], mem[ram.addr + 2], mem[ram.addr + 1], mem[ram.addr] };
  end
endmodule
