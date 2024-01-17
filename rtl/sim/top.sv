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
  gelato_ram_if ram;
  gelato_init_if init;

  assign init.valid = init_rdy;
  assign init.pc = 0;
  assign init.workers = `THREAD_NUM;

  gelato gelato (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .init(init),
    .ram(ram)
  );

  fake_ram fake_ram (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .ram(ram)
  );
endmodule
