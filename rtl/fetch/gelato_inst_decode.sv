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

  typedef enum {
    IDLE,
    UPDATE
  } status_t;

  inst_t   decoded_inst;  // Decoded instruction
  status_t status;


  function inst_t decode(addr_t pc, warp_num_t warp_num, data_t raw_inst);
    inst_t inst;

    inst.pc = pc;
    inst.warp_num = warp_num;
    inst.opcode = raw_inst[6:0];

    case (inst.opcode)
      `OPCODE_LUI, `OPCODE_AUIPC: begin
        inst.rd  = raw_inst[11:7];
        inst.imm = {raw_inst[31:12], 12'b0};
      end
      `OPCODE_JAL: begin
        inst.rd = raw_inst[11:7];
        inst.imm = {
          {12{raw_inst[31]}},
          raw_inst[19:12],
          raw_inst[20],
          raw_inst[30:21],
          1'b0
        };
      end
      `OPCODE_JALR: begin
        inst.rd  = raw_inst[11:7];
        inst.rs1 = raw_inst[19:15];
        inst.imm = {{20{raw_inst[31]}}, raw_inst[31:20]};
      end
      `OPCODE_BRANCH: begin
        inst.rs1 = raw_inst[19:15];
        inst.rs2 = raw_inst[24:20];
        inst.imm = {
          {20{raw_inst[31]}}, raw_inst[7], raw_inst[30:25], raw_inst[11:8], 1'b0
        };
      end
      `OPCODE_LOAD: begin
        inst.rd  = raw_inst[11:7];
        inst.rs1 = raw_inst[19:15];
        inst.imm = {{20{raw_inst[31]}}, raw_inst[31:20]};
      end
      `OPCODE_STORE: begin
        inst.rs1 = raw_inst[19:15];
        inst.rs2 = raw_inst[24:20];
        inst.imm = {{20{raw_inst[31]}}, raw_inst[31:25], raw_inst[11:7]};
      end
      `OPCODE_ARITHI: begin
        inst.rd  = raw_inst[11:7];
        inst.rs1 = raw_inst[19:15];
        inst.imm = {{20{raw_inst[31]}}, raw_inst[31:20]};
      end
      `OPCODE_ARITH: begin
        inst.rd  = raw_inst[11:7];
        inst.rs1 = raw_inst[19:15];
        inst.rs2 = raw_inst[24:20];
      end
      `OPCODE_NOP: begin
      end
      default: begin
        $fatal(0, "gelato_inst_decode: Invalid opcode");
      end
    endcase
  endfunction

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      status <= IDLE;
      inst_decoded_data.valid <= 0;
      inst_decoded_data.inst <= 0;
    end else if (rdy) begin
      case (status)
        IDLE: begin
          if (inst_raw_data.valid) begin
            inst_raw_data.valid <= 0;
            decoded_inst <= decode(
              inst_raw_data.pc, inst_raw_data.warp_num, inst_raw_data.inst
            );
            split_data.warp_num <= inst_raw_data.warp_num;
            split_data.split_table_num <= inst_raw_data.split_table_num;
            status <= UPDATE;
          end
          split_data.valid <= 0;
          inst_decoded_data.valid <= 0;
        end
        UPDATE: begin
          // Deliver the decoded instruction to the I-Buffer
          inst_decoded_data.inst  <= decoded_inst;

          inst_decoded_data.valid <= 1;

          $display(
            "Decode %h: opcode = %b, rd = %d, rs1 = %d, rs2 = %d, imm = %d",
            decoded_inst.pc, decoded_inst.opcode, decoded_inst.rd,
            decoded_inst.rs1, decoded_inst.rs2, decoded_inst.imm);

          // Update the split table
          split_data.valid <= 1;
          split_data.activate <=
            !(decoded_inst.opcode == `OPCODE_BRANCH &&
            (decoded_inst.funct3 == `FUNCT3_BEQD || decoded_inst.funct3 == `FUNCT3_BNED));
          if (decoded_inst.opcode == `OPCODE_AUIPC || decoded_inst.opcode == `OPCODE_BRANCH) begin
            split_data.stall <= 1;
          end else if (decoded_inst.opcode == `OPCODE_JAL || decoded_inst.opcode == `OPCODE_JALR) begin
            split_data.stall <= 0;
            split_data.updated_pc <= inst_raw_data.pc + decoded_inst.imm;
          end else begin
            split_data.stall <= 0;
            split_data.updated_pc <= inst_raw_data.pc + 4;
          end

          // Update status
          status <= IDLE;
        end
        default: begin
          $fatal(0, "gelato_inst_decode: Invalid status");
        end
      endcase
    end
  end
endmodule
