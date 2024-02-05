// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// This file contains the implementation of the FIFO used in the Gelato GPU.

module gelato_fifo #(
  parameter int WIDTH = 2,
  type T = logic
) (
  input logic clk,
  input logic rst_n,

  input logic din_valid,
  input T din,
  output logic din_ready,

  output logic dout_valid,
  output T dout,
  input logic dout_ready
);
  localparam int DEPTH = 1 << WIDTH;

  //=========================================================================
  // Write counter
  //=========================================================================

  logic [`WIDTH-1:0] wr_ptr_d, wr_ptr_q;
  logic wr_en;
  assign wr_en = din_valid && din_ready;
  assign wr_ptr_d = wr_en ? wr_ptr_q + 1 : wr_ptr_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr_q <= 0;
    end else begin
      wr_ptr_q <= wr_ptr_d;
    end
  end

  //=========================================================================
  // Read counter
  //=========================================================================
  logic [`WIDTH-1:0] rd_ptr_d, rd_ptr_q;
  logic rd_en;
  assign rd_en = dout_valid && dout_ready;
  assign rd_ptr_d = rd_en ? rd_ptr_q + 1 : rd_ptr_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr_q <= 0;
    end else begin
      rd_ptr_q <= rd_ptr_d;
    end
  end

  //=========================================================================
  // FIFO memory and output logic
  //=========================================================================
  T mem[DEPTH];
  assign dout = mem[rd_ptr];
  assign cnt_d = wr_ptr - rd_ptr;

  logic din_ready_en, din_ready_d, din_ready_q;
  assign din_ready_en = din_ready || (dout_valid && dout_ready);
  assign din_read_d = cnt_d < DEPTH - 1;
  assign din_ready = din_ready_q;

  logic dout_valid_en, dout_valid_d, dout_valid_q;
  assign dout_valid_en = dout_valid || (din_valid && din_ready);
  assign dout_valid_d = cnt_d > 0;
  assign dout_valid = dout_valid_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem <= '{default:0};
    end else begin
      if (wr_en) begin
        mem[wr_ptr] <= din;
      end
      if (din_ready_en) begin
        din_ready_q <= din_ready_d;
      end
      if (dout_valid_en) begin
        dout_valid_q <= dout_valid_d;
      end
    end
  end
endmodule
