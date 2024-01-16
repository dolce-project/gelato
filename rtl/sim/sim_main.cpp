#include "Vtop.h"

#include <fstream>
#include <verilated_vcd_c.h>

#include <iostream>

const int kMaxSimTime = 20000;

double sc_time_stamp() { return 0; }

inline auto HexToInt(char ch) -> int {
  return ch <= '9' ? ch - '0' : (ch - 'A') + 10;
}

void InitRam(Vtop *top) {
  char input_str[10];
  int current_address = 0x0;
  std::ifstream fin("testspace/test.data");
  while (fin >> input_str) {
    if (input_str[0] == '@') {
      current_address = 0x0;
      for (int i = 1; i <= 8; i++) {
        current_address = (current_address << 4) + HexToInt(input_str[i]);
      }
    } else {
      char current_data = (HexToInt(input_str[0]) << 4) + HexToInt(input_str[1]);
      top->top__DOT__fake_ram__DOT__mem[current_address++] = current_data;
    }
  }
}

int main(int argc, char **argv, char **env) {
  Vtop *top = new Vtop;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  top->trace(m_trace, 5);
  m_trace->open("testspace/test.vcd");

  InitRam(top);

  int sim_time = 0;
  while (sim_time < kMaxSimTime) {
    top->clk = !top->clk;
    top->init_rdy = 1;
    if (sim_time < 4) {
      top->rdy = 0;
      top->rst_n = 0;
    } else {
      top->rdy = 1;
      top->rst_n = 1;
    }

    top->eval();
    m_trace->dump(sim_time);
    sim_time++;
  }

  m_trace->close();
  delete top;
  return 0;
}