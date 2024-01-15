// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction fetch unit of the Gelato GPU.

module gelato_inst_fetch (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // PC-Table <-> I-Cache
  gelato_fetchskd_ifetch_if.slave inst_pc,

  // I-Cache <-> I-Fetch
  gelato_l1_cache_if.slave inst_cache_request,

  // I-Fetch <-> I-Buffer
  gelato_ifetch_idecode_if.master inst_raw_data
);

  typedef enum { IDLE, WAIT_MEM } status_t;
  status_t status;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      status <= IDLE;
    end else if (rdy) begin
      case (status)
        IDLE: begin
          if (inst_pc.valid) begin
            // Initialize the raw data
            inst_raw_data.valid <= 0;
            inst_raw_data.pc <= inst_pc.pc;
            inst_raw_data.warp_num <= inst_pc.warp_num;
            inst_raw_data.split_table_num <= inst_pc.split_table_num;

            // Send the request to the I-Cache
            inst_cache_request.valid <= 1;
            inst_cache_request.addr <= inst_pc.pc;

            // Update status
            inst_pc.ready <= 1;
            status <= WAIT_MEM;
          end
        end
        WAIT_MEM: begin
          if (inst_cache_request.valid) begin
            // Send the raw data to the I-Buffer
            inst_raw_data.valid <= 1;
            inst_raw_data.inst <= inst_cache_request.data;

            // Update status
            inst_pc.ready <= 0;
            status <= IDLE;
          end
        end
        default: begin
          $fatal(0, "gelato_inst_fetch: Invalid status");
        end
      endcase
    end
  end
endmodule
