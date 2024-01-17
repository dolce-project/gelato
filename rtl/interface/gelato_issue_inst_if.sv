// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

interface gelato_issue_inst_if;
  import gelato_types::*;

  logic valid;
  inst_t inst;
  warp_reg_t src[`RS_INDEX];

  // Operand collector -> Execute unit
  modport master(inout valid, output inst, output src);

  // Execute unit -> Operand collector
  modport slave(inout valid, input inst, input src);
endinterface
