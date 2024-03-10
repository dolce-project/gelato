// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the instruction decode unit of the Gelato GPU.

`include "gelato_macros.svh"
`include "gelato_types.svh"

import gelato_types::*;

module gelato_inst_decode (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  // Update split data
  gelato_idecode_split_if.master split_data,

  // Get the instruction raw data from ifetch
  input logic din_valid,
  output logic din_ready,
  input inst_raw_data_t din,

  // Send the decoded instruction to ibuffer
  output logic dout_valid,
  input logic dout_ready,
  output inst_decoded_data_t dout
);

  //============================================================================
  // Transition of state
  //============================================================================
  typedef enum {
    IDLE,
    DECODE,
    UPDATE
  } state_t;

  state_t state_q, state_d;
  inst_raw_data_t inst_raw_data_q, inst_raw_data_d;  // Raw instruction
  inst_t decoded_inst_q, decoded_inst_d;  // Decoded instruction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_d;
      inst_raw_data_q <= inst_raw_data_d;
      decoded_inst_q <= decoded_inst_d;
    end
  end

  //============================================================================
  // Condition of state transition
  //============================================================================
  always_comb begin
    case (state_q)
      IDLE: begin
        if (inst_raw_data.valid) begin
          state_d = DECODE;
          inst_raw_data_d = inst_raw_data;
        end
      end
      DECODE: begin
        decoded_inst_d.pc = inst_raw_data_q.pc;
        decoded_inst_d.warp_num = inst_raw_data_q.warp_num;
        decoded_inst_d.opcode = inst_raw_data_q.inst_raw_data[6:0];
        case (inst.opcode)
          `OPCODE_LUI, `OPCODE_AUIPC: begin
            decoded_inst_d.rd  = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.imm = {inst_raw_data_q.inst_raw_data[31:12], 12'b0};
          end
          `OPCODE_JAL: begin
            decoded_inst_d.rd = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.imm = {
              {12{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[19:12],
              inst_raw_data_q.inst_raw_data[20],
              inst_raw_data_q.inst_raw_data[30:21],
              1'b0
            };
          end
          `OPCODE_JALR: begin
            decoded_inst_d.rd = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.imm = {
              {20{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[31:20]
            };
          end
          `OPCODE_BRANCH: begin
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.rs2 = inst_raw_data_q.inst_raw_data[24:20];
            decoded_inst_d.imm = {
              {20{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[7],
              inst_raw_data_q.inst_raw_data[30:25],
              inst_raw_data_q.inst_raw_data[11:8],
              1'b0
            };
          end
          `OPCODE_LOAD: begin
            decoded_inst_d.rd = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.imm = {
              {20{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[31:20]
            };
          end
          `OPCODE_STORE: begin
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.rs2 = inst_raw_data_q.inst_raw_data[24:20];
            decoded_inst_d.imm = {
              {20{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[31:25],
              inst_raw_data_q.inst_raw_data[11:7]
            };
          end
          `OPCODE_ARITHI: begin
            decoded_inst_d.rd = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.imm = {
              {20{inst_raw_data_q.inst_raw_data[31]}},
              inst_raw_data_q.inst_raw_data[31:20]
            };
          end
          `OPCODE_ARITH: begin
            decoded_inst_d.rd  = inst_raw_data_q.inst_raw_data[11:7];
            decoded_inst_d.rs1 = inst_raw_data_q.inst_raw_data[19:15];
            decoded_inst_d.rs2 = inst_raw_data_q.inst_raw_data[24:20];
          end
          `OPCODE_NOP: begin
          end
          default: begin
            $fatal(0, "gelato_inst_decode: Invalid opcode");
          end
        endcase
        state_d = UPDATE;
      end
      UPDATE: begin
        state_d = IDLE;
      end
      default: begin
        $fatal(0, "gelato_inst_decode: Invalid state");
      end
    endcase
  end

  //============================================================================
  // Output
  //============================================================================
  always_comb begin
    if (!rst_n) begin
      dout_valid = 0;
      dout = 0;
    end else if (rdy) begin
      case (state_q)
        IDLE: begin
          dout_valid = 0;
          din_ready  = 1;
        end
        DECODE: begin
          din_ready = 0;
        end
        UPDATE: begin
          // Deliver the decoded instruction to the I-Buffer
          dout_valid = 1;
          dout = decoded_inst_q;
          $display(
            "Decode %h: opcode = %b, rd = %d, rs1 = %d, rs2 = %d, imm = %d",
            decoded_inst_q.pc, decoded_inst_q.opcode, decoded_inst_q.rd,
            decoded_inst_q.rs1, decoded_inst_q.rs2, decoded_inst_q.imm);

          // Update the split table
          split_data.valid = 1;
          split_data.activate =
            !(decoded_inst_q.opcode == `OPCODE_BRANCH &&
            (decoded_inst_q.funct3 == `FUNCT3_BEQD || decoded_inst_q.funct3 == `FUNCT3_BNED));
          if (decoded_inst_q.opcode == `OPCODE_AUIPC || decoded_inst_q.opcode == `OPCODE_BRANCH) begin
            split_data.stall = 1;
          end else if (decoded_inst_q.opcode == `OPCODE_JAL || decoded_inst_q.opcode == `OPCODE_JALR) begin
            split_data.stall = 0;
            split_data.updated_pc = decoded_inst_q.pc + decoded_inst_q.imm;
          end else begin
            split_data.stall = 0;
            split_data.updated_pc = decoded_inst_q.pc + 4;
          end
        end
        default: begin
          $fatal(0, "gelato_inst_decode: Invalid status");
        end
      endcase
    end
  end
endmodule
