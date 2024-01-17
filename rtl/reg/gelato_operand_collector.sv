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
  gelato_exec_inst_if.master exec_mem_inst,
  gelato_exec_inst_if.master exec_compute_inst,
  gelato_exec_inst_if.master exec_tensor_inst
);
  import gelato_types::*;

  typedef enum {
    GENERATE_REQUEST,
    WAIT_RESPONSE
  } status_t;
  status_t status;

  collector_entry_t entries[`COLLECTOR_SIZE];
  logic ready[`COLLECTOR_SIZE];

  generate
    for (genvar i = 0; i < `COLLECTOR_SIZE; i++) begin : gen_collector_entries
      assign ready[i] = !entries[i].rs_valid1 & !entries[i].rs_valid2 & !entries[i].rs_valid3;
    end
  endgenerate

  logic full;
  collector_num_t empty_slot;
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
        empty_slot = i[1:0];
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
            request.entry_valid[i]   <= entries[i[1:0]+selected_entry].valid;
            request.collector_num[i] <= i[1:0] + selected_entry;
            request.reg_num[i][1] <= entries[i[1:0]+selected_entry].rs1;
            request.reg_num[i][2] <= entries[i[1:0]+selected_entry].rs2;
            request.reg_num[i][3] <= entries[i[1:0]+selected_entry].rs3;
            request.reg_valid[i][0] <= 0;
            request.reg_valid[i][1] <= entries[i[1:0]+selected_entry].rs_valid1;
            request.reg_valid[i][2] <= entries[i[1:0]+selected_entry].rs_valid2;
            request.reg_valid[i][3] <= entries[i[1:0]+selected_entry].rs_valid3;
          end
          request.valid <= 1;
          status <= WAIT_RESPONSE;
        end

        WAIT_RESPONSE: begin
          // Receive issued instruction
          if (issued_inst.valid && !full) begin
            $display("Received issued instruction %h", issued_inst.inst.pc);
            issued_inst.valid <= 0;
            entries[empty_slot] <= 1;
            entries[empty_slot].inst <= issued_inst.inst;
            entries[empty_slot].rs1 <= {
              {issued_inst.inst.rs1[4:3] + issued_inst.inst.warp_num},
              issued_inst.inst.rs1[2:0]
            };
            entries[empty_slot].rs2 <= {
              {issued_inst.inst.rs2[4:3] + issued_inst.inst.warp_num},
              issued_inst.inst.rs2[2:0]
            };
            entries[empty_slot].rs3 <= {
              {issued_inst.inst.rs3[4:3] + issued_inst.inst.warp_num},
              issued_inst.inst.rs3[2:0]
            };
            entries[empty_slot].rs_valid1 <= issued_inst.inst.rs1 != 0;
            entries[empty_slot].rs_valid2 <= issued_inst.inst.rs2 != 0;
            entries[empty_slot].rs_valid3 <= issued_inst.inst.rs3 != 0;
          end

          // Catch response
          if (response.valid) begin
            response.valid <= 0;
            foreach (data_valid[i]) begin
              if (data_valid[i]) begin
                case (response.reg_index[i])
                  1: begin
                    entries[response.collector_index[i]].rs_data1 <= response.data[i];
                    entries[response.collector_index[i]].rs_valid1 <= 0;
                  end
                  2: begin
                    entries[response.collector_index[i]].rs_data2 <= response.data[i];
                    entries[response.collector_index[i]].rs_valid2 <= 0;
                  end
                  3: begin
                    entries[response.collector_index[i]].rs_data3 <= response.data[i];
                    entries[response.collector_index[i]].rs_valid3 <= 0;
                  end
                  default: begin
                    $fatal(0, "Invalid reg index");
                  end
                endcase
              end
            end
            status <= GENERATE_REQUEST;
          end

          // Issue instruction to Load Store Unit
          foreach (entries[i]) begin
            if (entries[i].valid && ready[i]) begin
              if (entries[i].inst.opcode == `OPCODE_LOAD || entries[i].inst.opcode == `OPCODE_STORE) begin
                $display("Executing memory instruction %h", entries[i].inst.pc);
                exec_mem_inst.valid <= 1;
                exec_mem_inst.inst  <= entries[i].inst;
                exec_mem_inst.src1  <= entries[i].rs_data1;
                exec_mem_inst.src2  <= entries[i].rs_data2;
                exec_mem_inst.src3  <= entries[i].rs_data3;
                break;
              end
            end
          end

          // Issue instruction to Compute Unit
          foreach (entries[i]) begin
            if (entries[i].valid && ready[i]) begin
              if (entries[i].inst.opcode != `OPCODE_LOAD && entries[i].inst.opcode != `OPCODE_STORE && entries[i].inst.opcode != `OPCODE_TENSOR) begin
                $display("Executing compute instruction %h", entries[i].inst.pc);
                exec_compute_inst.valid <= 1;
                exec_compute_inst.inst  <= entries[i].inst;
                exec_compute_inst.src1  <= entries[i].rs_data1;
                exec_compute_inst.src2  <= entries[i].rs_data2;
                exec_compute_inst.src3  <= entries[i].rs_data3;
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
