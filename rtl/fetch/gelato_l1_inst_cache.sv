// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction cache of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_l1_inst_cache (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // From the instruction fetch unit
  gelato_l1_cache_if.master inst_cache_request,

  // To RAM
  gelato_ram_if.master fetch_data
);
  import gelato_types::*;

  // logic hit;
  // l1_cache_entry_t cache[`L1_ICACHE_LINE_NUM];
  // l1_cache_index_t index;
  // l1_cache_tag_t tag;
  // l1_cache_offset_t offset;

  // assign index = inst_cache_request.addr[`L1_CACHE_INDEX_INDEX];
  // assign tag = inst_cache_request.addr[`L1_CACHE_INDEX_TAG];
  // assign offset = inst_cache_request.addr[`L1_CACHE_OFFSET_INDEX];

  // always_comb begin
  //   if (inst_cache_request.valid) begin
  //     hit = cache[index].valid && (cache[index].tag == tag);
  //     if (hit) begin
  //       fetch_data.done = 1;
  //       fetch_data.data = cache[index].data;
  //     end
  //   end
  // end

  assign fetch_data.valid = inst_cache_request.valid;
  assign fetch_data.addr = inst_cache_request.addr;
  assign inst_cache_request.done = fetch_data.done;
  assign inst_cache_request.data = fetch_data.data;

endmodule
