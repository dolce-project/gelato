// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the register file arbiter of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_register_file_arbiter (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_register_update_if.master update,
  gelato_register_collect_request_if.slave request,
  gelato_register_collect_response_if.master response
);
  import gelato_types::*;

  typedef enum {
    IDLE,
    RESPONSE
  } status_t;
  status_t status;

  logic valid[`BANK_NUM];
  reg_num_t reg_num[`BANK_NUM];
  warp_num_t warp_num[`BANK_NUM];
  collector_num_t collector_index[`BANK_NUM];
  rs_num_t reg_index[`BANK_NUM];

  // Request
  logic reg_valid[`COLLECTOR_SIZE][4];
  assign reg_valid = request.reg_valid;

  always_comb begin
    if (request.valid) begin
      foreach (valid[i]) begin
        valid[i] = 0;
      end
      foreach (reg_valid[i, j]) begin
        if (request.entry_valid[i] && request.reg_valid[i][j] && !valid[request.reg_num[i][j][4:3]]) begin
          valid[request.reg_num[i][j][4:3]] = 1;
          reg_num[request.reg_num[i][j][4:3]] = request.reg_num[i][j];
          warp_num[request.reg_num[i][j][4:3]] = request.warp_num[i];
          collector_index[request.reg_num[i][j][4:3]] = request.collector_num[i];
          reg_index[request.reg_num[i][j][4:3]] = j[1:0];
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
      response.valid <= 0;
    end else begin
      case (status)
        IDLE: begin
          if (request.valid) begin
            request.valid <= 0;
            update.reg_num <= reg_num;
            update.warp_num <= warp_num;
            status <= RESPONSE;
          end
        end
        RESPONSE: begin
          response.valid <= 1;
          response.data_valid <= valid;
          response.data <= update.data;
          foreach (collector_index[i]) begin
            response.collector_index[i] <= collector_index[i];
            response.reg_index[i] <= reg_index[i];
          end
          status <= IDLE;
        end
        default: begin
          $fatal(0, "Invalid status");
        end
      endcase
    end
  end

endmodule
