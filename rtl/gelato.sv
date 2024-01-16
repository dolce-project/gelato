// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Top module of the Gelato GPU

module gelato (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_init_if.slave init,
  gelato_ram_if.slave ram
);
  gelato_frontend frontend (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .init(init),
    .fetch_data(ram)
  );
endmodule
