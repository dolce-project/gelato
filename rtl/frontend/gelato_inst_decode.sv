// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction decode unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

module gelato_inst_decode (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_ifetch_idecode_if.slave inst_raw_data,  // From I-Fetch
  gelato_idecode_split_if.master split_data,  // To split table, get thread mask and update table
  gelato_idecode_ibuffer_if.master inst_decoded_data  // To I-Buffer
);
  import gelato_types::*;

  assign inst_decoded_data.thread_mask = split_data.thread_mask;

  inst_t inst;  // Decoded instruction

  always_comb begin  // Decode instruction by combinational logic
    inst.opcode = inst_raw_data.inst[31:25];
    case (inst.opcode)
      `OPCODE_LUI, `OPCODE_AUIPC: begin
        inst.rd  = inst_raw_data.inst[11:7];
        inst.imm = inst_raw_data.inst[31:12];
      end
      `OPCODE_JAL: begin
        inst.rd = inst_raw_data.inst[11:7];
        inst.imm = {
          {12{inst_raw_data.inst[31]}},
          inst_raw_data.inst[19:12],
          inst_raw_data.inst[20],
          inst_raw_data.inst[30:21],
          1'b0
        };
      end
      `OPCODE_JALR: begin
        inst.rd  = inst_raw_data.inst[11:7];
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.imm = {{20{inst_raw_data.inst[31]}}, inst_raw_data.inst[31:20]};
      end
      `OPCODE_BRANCH: begin
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.rs2 = inst_raw_data.inst[24:20];
        inst.imm = {
          {20{inst_raw_data.inst[31]}},
          inst_raw_data.inst[7],
          inst_raw_data.inst[30:25],
          inst_raw_data.inst[11:8],
          1'b0
        };
      end
      `OPCODE_LOAD: begin
        inst.rd  = inst_raw_data.inst[11:7];
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.imm = {{20{inst_raw_data.inst[31]}}, inst_raw_data.inst[31:20]};
      end
      `OPCODE_STORE: begin
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.rs2 = inst_raw_data.inst[24:20];
        inst.imm = {
          {20{inst_raw_data.inst[31]}}, inst_raw_data.inst[31:25], inst_raw_data.inst[11:7]
        };
      end
      `OPCODE_ARITHI: begin
        inst.rd  = inst_raw_data.inst[11:7];
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.imm = {{20{inst_raw_data.inst[31]}}, inst_raw_data.inst[31:20]};
      end
      `OPCODE_ARITH: begin
        inst.rd  = inst_raw_data.inst[11:7];
        inst.rs1 = inst_raw_data.inst[19:15];
        inst.rs2 = inst_raw_data.inst[24:20];
      end
      default: begin
        $fatal(0, "gelato_inst_decode: Invalid opcode");
      end
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      inst_decoded_data.valid <= 1'b0;
      inst_decoded_data.inst  <= 0;
    end else if (rdy && inst_raw_data.valid) begin
      // Deliver the decoded instruction to the I-Buffer
      inst_decoded_data.valid <= 1;
      inst_decoded_data.pc <= inst_raw_data.pc;
      inst_decoded_data.warp_num <= inst_raw_data.warp_num;
      inst_decoded_data.thread_mask <= split_data.thread_mask;
      inst_decoded_data.inst <= inst;

      // Update the split table
      split_data.valid <= 1;
      split_data.warp_num <= inst_raw_data.warp_num;
      split_data.split_table <= inst_raw_data.split_table_num;

      if (inst.opcode == `OPCODE_AUIPC || inst.opcode == `OPCODE_BRANCH) begin
        split_data.stall <= 1;
      end else if (inst.opcode == `OPCODE_JAL || inst.opcode == `OPCODE_JALR) begin
        split_data.stall <= 0;
        split_data.updated_pc <= inst_raw_data.pc + inst.imm;
      end else begin
        split_data.stall <= 0;
        split_data.updated_pc <= inst_raw_data.pc + 4;
      end
    end
  end
endmodule
