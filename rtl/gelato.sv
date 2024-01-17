// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Top module of the Gelato GPU

module gelato (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  gelato_init_if.slave init,
  gelato_ram_if.slave ram
);
  gelato_idecode_ibuffer_if inst_decoded_data;
  gelato_ibuffer_fetchskd_if buffer_status;

  gelato_ram_if inst_ram;
  gelato_ram_if data_ram;

  gelato_fetch fetch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .init(init),
    .inst_decoded_data(inst_decoded_data),
    .fetch_data(inst_ram),
    .buffer_status(buffer_status)
  );

  gelato_warpskd_collector_if issued_inst;

  gelato_dispatch dispatch_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .inst_decoded_data(inst_decoded_data),
    .issued_inst(issued_inst),
    .buffer_status(buffer_status),
    .reg_wb(reg_wb[0])
  );

  gelato_exec_inst_if exec_compute_inst;
  gelato_exec_inst_if exec_mem_inst;
  gelato_exec_inst_if exec_tensor_inst;

  gelato_register_file register_file (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .issued_inst(issued_inst),
    .exec_compute_inst(exec_compute_inst),
    .exec_mem_inst(exec_mem_inst),
    .exec_tensor_inst(exec_tensor_inst),
    .reg_wb(reg_wb[0])
  );

  gelato_reg_wb_if reg_wb[3];
  logic wb_valid[3];

  gelato_compute compute_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .exec_inst(exec_compute_inst),
    .reg_wb(reg_wb[0])
  );

  gelato_load_store load_store_unit (
    .clk(clk),
    .rst_n(rst_n),
    .rdy(rdy),
    .exec_inst(exec_mem_inst),
    .ram(data_ram),
    .reg_wb(reg_wb[1])
  );

  logic [1:0] last_wb_signal, next_wb_signal;

  always_comb begin
    logic [1:0] i = last_wb_signal + 1;
    repeat (3) begin
      if (i == 3) begin
        i = 0;
      end
      if (wb_valid[i]) begin
        next_wb_signal = i;
        break;
      end
      i++;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      last_wb_signal <= 0;
    end else begin
      if (!wb_valid[last_wb_signal] && wb_valid[next_wb_signal]) begin
        last_wb_signal <= next_wb_signal;
      end
    end
  end
endmodule
