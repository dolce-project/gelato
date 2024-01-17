// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// Queue for Gelato GPU

module gelato_queue #(
  type T = logic,
  parameter int WIDTH = 0
) (
  input logic clk,
  input logic rst_n,
  input logic rdy,

  input logic push_enabled,
  input T push_data,

  input logic pop_enabled,
  output T tail_data,

  output logic empty,
  output logic full
);
  localparam integer SIZE = 1 << WIDTH;

  logic valid[SIZE];
  T data[SIZE];

  logic [WIDTH-1:0] head;
  logic [WIDTH-1:0] tail;

  assign empty = head == tail;
  assign full = head + 1 == tail;
  assign tail_data = data[tail];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      head <= 0;
      tail <= 0;
      foreach (valid[i]) begin
        valid[i] <= 0;
      end
    end else begin
      if (push_enabled && !full) begin
        data[head] <= push_data;
        valid[head] <= 1;
        head <= head + 1;
      end
      if (pop_enabled && !empty) begin
        valid[tail] <= 0;
        tail <= tail + 1;
      end
    end
  end
endmodule
