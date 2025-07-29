
4-Bit Hybrid Carry Lookahead Adder in Verilog

This repository contains the Verilog source code for a novel 4-bit adder. 
This design implements a hybrid carry propagation scheme, combining a fast Carry Lookahead Unit with a per-bit-slice carry calculation.
A unique voter module is used at each stage to select the final carry in case error occured using partial Triple Modular Redundency.


🏛️ Architecture Overview

The adder's architecture is not a standard Carry Lookahead Adder (CLA) or Ripple Carry Adder (RCA). 
It operates by computing carries in two parallel paths and then selecting the result.

Carry Lookahead Path: A CGL (Carry Generation Logic) module runs in parallel to the main datapath.
It computes all four carry-out signals (c_cgl[3:0]) simultaneously, directly from the primary inputs A, B, and Cin. This is the "fast" path.

Bit-Slice Path: The adder is composed of four BitSlice_new instances.Each BitSlice_new is a 1-bit full adder that calculates the sum bit and two local carry-out signals (ci1 and ci2).
These slices are chained in a ripple-carry-like fashion.

Voter Selection: At each stage i (from 1 to 3), a voter module selects the carry that will be used for the next stage. It takes three inputs:

1.The local carry from the current BitSlice_new.

2.A redundant local carry from the current BitSlice_new.

3.The pre-computed carry from the CGL module (c_cgl[i-1]).

The final carry-out of the 4-bit adder is the output from the last voter module, in case if error is occured.
