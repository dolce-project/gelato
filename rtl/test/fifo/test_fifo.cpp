#include "Vtop.h"

#include <verilated_vcd_c.h>

const int kMaxSimTime = 20;


int main(int argc, char **argv, char **env) {
  Vtop *top = new Vtop;

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  top->trace(m_trace, 5);
  m_trace->open("testspace/test.vcd");

  int sim_time = 0;
  int clock_cycle = 0;
  while (sim_time < kMaxSimTime) {
    top->clk = !top->clk;
    if (top->clk == 1) {
      printf("clock cycle: %d\n", clock_cycle++);
    }
    if (sim_time < 4) {
      top->rst_n = 0;
    } else {
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
