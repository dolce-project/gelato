// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Testbench of the Gelato GPU

module top (
  input logic clk,
  input logic rst_n,
  input logic rdy,
  input logic init_rdy
);
  gelato_ram_if ram_if;
  gelato_init_warp_if init_if;

  assign init_if.valid = init_rdy;
  assign init_if.pc = 0;
  assign init_if.workers = `THREAD_NUM;

  gelato gpu (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy)
  );

  fake_ram ram (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .ram(ram_if)
  );
endmodule
