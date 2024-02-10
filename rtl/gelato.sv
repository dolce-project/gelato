// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Top level module of the Gelato GPU

module gelato (
  input logic clk,
  input logic rst_n,
  input logic rdy
);
  gelato_init_sm_if init[`SM_NUM];
  gelato_l2_cache_if inst_cache_request[`SM_NUM];
  gelato_l2_cache_if data_cache_request[`SM_NUM];

  generate;
    for (genvar i = 0; i < `SM_NUM; i++) begin: gen_sm
      gelato_sm sm (
        .clk(clk),
        .rst_n(rst_n),
        .rdy(rdy),
        .init_sm(init),
        .inst_cache_request(inst_cache_request),
        .data_cache_request(data_cache_request)
      );
    end
  endgenerate
endmodule
