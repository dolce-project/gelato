// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the operand collector of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_operand_collector (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_warpskd_collector_if.slave issued_inst,
  gelato_register_collect_request_if.master request,
  gelato_register_collect_response_if.slave response,
  gelato_issue_inst_if.master issued_mem_inst,
  gelato_issue_inst_if.master issued_compute_inst,
  gelato_issue_inst_if.master issued_tensor_inst
);
  import gelato_types::*;

  typedef enum {
    GENERATE_REQUEST,
    WAIT_RESPONSE
  } status_t;
  status_t status;

  collector_entry_t entries[`COLLECTOR_SIZE];

  generate
    for (genvar i = 0; i < `COLLECTOR_SIZE; i++) begin : gen_collector_entries
      assign entries[i].rs[1] = {
        {entries[i].inst.rs1[4:3] + entries[i].inst.warp_num}, entries[i].inst.rs1[2:0]
      };
      assign entries[i].rs[2] = {
        {entries[i].inst.rs2[4:3] + entries[i].inst.warp_num}, entries[i].inst.rs2[2:0]
      };
      assign entries[i].rs[3] = {
        {entries[i].inst.rs3[4:3] + entries[i].inst.warp_num}, entries[i].inst.rs3[2:0]
      };
      assign entries[i].ready = !entries[i].rs_valid[1] & !entries[i].rs_valid[2] & !entries[i].rs_valid[3];
    end
  endgenerate

  logic full;
  logic empty_slot;
  collector_num_t selected_entry;

  // Response data
  logic data_valid[`BANK_NUM];
  assign data_valid = response.data_valid;

  // Genereate full and empty_slot
  always_comb begin
    full = 1;
    foreach (entries[i]) begin
      if (!entries[i].valid) begin
        full = 0;
        empty_slot = i;
        break;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      foreach (entries[i]) begin
        entries[i].valid <= 0;
      end
    end else if (rdy) begin
      case (status)
        GENERATE_REQUEST: begin
          foreach (entries[i]) begin
            request.entry_valid[i] <= entries[i+selected_entry].valid;
            request.reg_num[i] <= entries[i+selected_entry].rs;
            request.reg_valid[i] <= entries[i+selected_entry].rs_valid;
            request.collector_num[i] <= i + selected_entry;
          end
          request.valid <= 1;
          status <= WAIT_RESPONSE;
        end
        WAIT_RESPONSE: begin
          if (issued_inst.valid && !full) begin
            issued_inst.caught <= 1;
            entries[empty_slot] <= 1;
            entries[empty_slot].inst <= issued_inst.inst;
            entries[empty_slot].rs_valid[1] <= issued_inst.inst.rs1 != 0;
            entries[empty_slot].rs_valid[2] <= issued_inst.inst.rs2 != 0;
            entries[empty_slot].rs_valid[3] <= issued_inst.inst.rs3 != 0;
          end

          // Catch response
          if (response.valid) begin
            response.valid <= 0;
            foreach (data_valid[i]) begin
              if (data_valid[i]) begin
                entries[response.collector_index[i]].rs_data[response.reg_index[i]] <= response.data[i];
                entries[response.collector_index[i]].rs_valid[response.reg_index[i]] <= 0;
              end
            end
            status <= GENERATE_REQUEST;
          end

          // Issue instruction to Load Store Unit
          foreach (entries[i]) begin
            if (entries[i].valid && entries[i].ready) begin
              if (entries[i].inst.opcode == `OPCODE_LOAD || entries[i].inst.opcode == `OPCODE_STORE) begin
                issued_mem_inst.valid <= 1;
                issued_mem_inst.inst  <= entries[i].inst;
                issued_mem_inst.src   <= entries[i].rs_data;
                break;
              end
            end
          end

          // Issue instruction to Compute Unit
          foreach (entries[i]) begin
            if (entries[i].valid && entries[i].ready) begin
              if (entries[i].inst.opcode != `OPCODE_LOAD && entries[i].inst.opcode != `OPCODE_STORE && entries[i].inst.opcode != `OPCODE_TENSOR) begin
                issued_compute_inst.valid <= 1;
                issued_compute_inst.inst  <= entries[i].inst;
                issued_compute_inst.src   <= entries[i].rs_data;
                break;
              end
            end
          end
        end
        default: begin
          $fatal(0, "Invalid status");
        end
      endcase
    end
  end

endmodule