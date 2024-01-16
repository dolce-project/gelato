// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

`include "gelato_types.svh"

interface gelato_split_table_select_pc_if;
  import gelato_types::*;

  // PC Table information
  logic valid;
  addr_t pc;
  split_table_num_t split_table_num;

  // Warp Split Table -> Split Table
  modport master(output valid, output pc, output split_table_num);

  // Split Table -> Warp Split Table
  modport slave(input valid, input pc, input split_table_num);

endinterface

interface gelato_split_table_update_pc_if;
  import gelato_types::*;

  // Update information
  logic valid;
  logic stall;
  addr_t pc;
  split_table_num_t split_table_num;
  thread_mask_t thread_mask;

  // Split Table -> Warp Split Table
  modport master(output valid, output stall, output pc, output split_table_num, input thread_mask);

  // Warp Split Table -> Split Table
  modport slave(input valid, input stall, input pc, input split_table_num, output thread_mask);
endinterface

interface gelato_split_table_wb_if;
  import gelato_types::*;

  // Update information
  logic valid;
endinterface
