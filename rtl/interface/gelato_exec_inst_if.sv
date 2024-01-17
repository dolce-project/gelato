// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

interface gelato_exec_inst_if;
  import gelato_types::*;

  logic valid;
  inst_t inst;
  warp_reg_t rs1, rs2, rs3;

  // Temporary information for collector update
  logic collector_index_valid;
  collector_num_t collector_index;

  // Operand collector -> Execute unit
  modport master(inout valid, inout collector_index_valid, inout collector_index, output inst, output rs1, output rs2, output rs3);

  // Execute unit -> Operand collector
  modport slave(inout valid, input inst, input rs1, input rs2, input rs3);
endinterface
