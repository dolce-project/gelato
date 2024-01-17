// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the load store unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_load_store (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_exec_inst_if.slave exec_inst,
  gelato_ram_if.master ram,
  gelato_reg_wb_if.master reg_wb
);
  import gelato_types::*;

  typedef enum {
    IDLE,
    MEM,
    WAIT_MEM
  } status_t;
  integer thread_count;
  addr_t addr[`THREAD_NUM];
  data_t write_data[`THREAD_NUM];
  data_t load_data[`THREAD_NUM];
  status_t status;

  warp_reg_t warp_data;

  generate
    for (genvar i = 0; i < `THREAD_NUM; i++) begin : gen_warp_data
      assign addr[i] = exec_inst.inst.thread_mask[i] ?
        exec_inst.rs1[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH] + exec_inst.inst.imm : 0;
      assign write_data[i] = exec_inst.rs2[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH];
      assign warp_data[(i+1)*`DATA_WIDTH-1:i*`DATA_WIDTH] = load_data[i];
    end
  endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_wb.valid <= 0;
    end else if (rdy) begin
      case (status)
        IDLE: begin
          if (exec_inst.valid) begin
            thread_count <= 0;
            status <= MEM;
          end
        end
        MEM: begin
          if (thread_count == `THREAD_NUM) begin
            exec_inst.valid <= 0;
            if (exec_inst.inst.opcode == `OPCODE_LOAD) begin
              reg_wb.valid <= 1;
              reg_wb.caught <= 0;
              reg_wb.reg_num <= exec_inst.inst.rd;
              reg_wb.warp_num <= exec_inst.inst.warp_num;
              reg_wb.thread_mask <= exec_inst.inst.thread_mask;
              reg_wb.data <= warp_data;
            end
            status <= IDLE;
          end else begin
            if (addr[thread_count] == 0) begin
              thread_count <= thread_count + 1;
            end else if (exec_inst.inst.opcode == `OPCODE_LOAD) begin
              ram.valid <= 1;
              ram.write <= 0;
              ram.addr  <= addr[thread_count];
            end else if (exec_inst.inst.opcode == `OPCODE_STORE) begin
              ram.valid <= 1;
              ram.write <= 1;
              ram.addr  <= addr[thread_count];
              ram.data  <= write_data[thread_count];
            end
          end
        end
        WAIT_MEM: begin
          if (ram.done) begin
            if (exec_inst.inst.opcode == `OPCODE_LOAD) begin
              load_data[thread_count] <= ram.data;
            end
            thread_count <= thread_count + 1;
            status <= MEM;
          end
        end
        default: begin
          $fatal(0, "LSU: Invalid status");
        end
      endcase
    end
  end
endmodule
