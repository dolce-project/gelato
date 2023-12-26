# ISA Extension of Gelato

## Overview

In Gelato, we introduce a new ISA extension to RISC-V in order to support SIMT computing model, which is widely used in modern GPGPU and their ISA. The extension mainly handles the problem of control flow divergence and synchronization of threads and warps. Besides, we also add some computing instructions to accelerate specific computing tasks.

We add following instructions to the RISC-V ISA to handle divergence and synchronization of threads and warps.
1. `bra rs1, rs2, imm`
  - B-type instruction.
  - splits the threads according to the value of `rs1` (==/!= 0) into two groups, one starts at `pc + imm`, the other starts at `pc + 4`. Finally, they reconverge at `pc + rs2`.
2. `select rd, rs1, rs2, rs3` 
  - R-type instruction.
  - selects the value of `rs2` or `rs3` according to the value of `rs1`, and stores the result back in it.
3. `bar imm`
  - I-type instruction.
  - Store this barrier at the `imm1`-th barrier slot of the block, and wait until `imm2` threads in the warp/block have reached this barrier.

We also add following instructions to accelerate matrix computations.
1. `mload rd, rs1, imm`
  - I-type instruction.
  - Load the `funct3`-th segment of the matrix at `rs1 + imm` to `rd`.
2. `mstore rs1, rs2, imm`
  - S-type instruction.
  - Store the value of `rs2` to the `funct3`-th segment of the matrix at `rs1 + imm`.
3. `mmadd rd, rs1, rs2, rs3`
  - R-type instruction.
  - Matrix multiplication and addition. `rd = rs1 * rs2 + rs3`. Execute `funct3`-th segment of a multiplication.
