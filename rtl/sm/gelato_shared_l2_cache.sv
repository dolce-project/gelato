// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the shared L2 cache of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_shared_l2_cache (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // From the instruction fetch unit
  gelato_l2_cache_if.master inst_request[5],

  // To L2 Cache
  gelato_l2_cache_if.master fetch_data
);
  import gelato_types::*;

  typedef enum { IDLE, WAIT_MEM } status_t;
  status_t status;

  logic hit;
  l1_cache_entry_t cache[`L1_ICACHE_LINE_NUM][4];
  l1_cache_index_t index;
  l1_cache_tag_t tag;
  l1_cache_offset_t offset;

  assign hit = cache[index].valid && cache[index].tag == tag;
  assign index = inst_request.addr[`L1_CACHE_INDEX_INDEX];
  assign tag = inst_request.addr[`L1_CACHE_TAG_INDEX];
  assign offset = inst_request.addr[`L1_CACHE_OFFSET_INDEX];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // cache <= '{default:0};
    end else begin
      case (status)
        IDLE: begin
          if (inst_request.valid) begin
            if (hit) begin // done
              inst_request.valid <= 0;
              inst_request.done <= 1;
              inst_request.data <= {cache[index].data[offset + 3], cache[index].data[offset + 2], cache[index].data[offset + 1], cache[index].data[offset]};
            end else begin // wait for memory
              inst_request.done <= 0;
              inst_request.data <= 0;
              fetch_data.valid <= 1;
              fetch_data.addr <= inst_request.addr;
              status <= WAIT_MEM;
            end
          end
        end
        WAIT_MEM: begin
          if (fetch_data.done) begin
            cache[index].valid <= 1;
            cache[index].tag <= tag;
            cache[index].data <= fetch_data.data;
            inst_request.valid <= 0;
            inst_request.done <= 1;
            inst_request.data <= {fetch_data.data[offset + 3], fetch_data.data[offset + 2], fetch_data.data[offset + 1], fetch_data.data[offset]};
            fetch_data.valid <= 0;
            status <= IDLE;
          end
        end
        default: begin
          $fatal(0, "gelato_l1_inst_cache: Invalid status");
        end
      endcase
    end
  end
endmodule
