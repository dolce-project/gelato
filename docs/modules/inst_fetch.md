# Documentation of the Instruction Module

## Overview

The fetch of instruction was divided into three stages: fetch, decode and update split table. The module contains a fetch scheduler, a fetcher, a decoder, a split table (with PC table) and I-Cache. First, the fetch scheduler will choose a live warp whose buffer is not full and send the information to fetcher. The fetcher will try to fetch this instruction from I-Cache and send the instruction to decoder. Since the decoder does not need to handle any stall, the instruction will be immediately decoded in the next cycle and the decoded data will be used to update the split table and delivered to the instruction buffer.

## Details

### Instruction Fetcher

The instruction fetcher has two status: WAIT_MEM. When it is in the IDLE status, it receives a new instruction information from fetch scheduler. If I-Cache hits, it turns its status to IDLE and send the instruction to decoder. Otherwise, it turns its status to WAIT_MEM and send the request to I-Cache.

### Instruction Decoder

The instruction decoder receives the instruction from fetcher and decode it in one cycle. The decoded data will be used to update the split table and delivered to the instruction buffer.

### Split Table

The split table records the information of branch divergence of each warp. It updates the information according to the decoded data from decoder. Then it will generate a new PC for each warp and send it to fetch scheduler.