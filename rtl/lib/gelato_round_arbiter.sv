// Copyright (c) 2023 Conless Pan

// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

module gelato_round_arbiter #(
  parameter int PORT_NUM_WIDTH = 2,
  parameter int STEP_LENGTH = 2
) (
  input logic clk,
  input logic rst_n,

  input logic [2**PORT_NUM_WIDTH-1:0] req,
  output logic [PORT_NUM_WIDTH-1:0] selected
);

  logic [PORT_NUM_WIDTH-1:0] selected_q, selected_d;

  always_comb begin
    if (req[selected_q]) begin
      selected_d = selected_q;
    end else if (req[selected_q+1]) begin
      selected_d = selected_q + 1;
    end else begin
      selected_d = selected_q + 2;
    end
  end

  assign selected = selected_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      selected_q <= 0;
    end else begin
      selected_q <= selected_d;
    end
  end
endmodule
