# ISA Extension of Gelato

## Overview

In Gelato, we introduce a new ISA extension to RISC-V in order to support SIMT computing model, which is widely used in modern GPGPU and their ISA. The extension mainly handles the problem of control flow divergence and synchronization of threads and warps. Besides, we also add some computing instructions to accelerate specific computing tasks.

We add following instructions to the RISC-V ISA:
1. `bra rs1, rs2, rs3`
  - B-type instruction.
  - splits the threads according to the value of `rs1` into two groups, one starts at `pc + rs2`, the other starts at `pc + 4`. Finally, they reconverge at `pc + rs3`.
2. `select rd, rs1, rs2, rs3` 
  - R-type instruction.
  - selects the value of `rs2` or `rs3` according to the value of `rs1`, and stores the result back in it.
3. 