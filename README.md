# Introduction
The RV64G Core is a 64-bit RISC-V compliant core designed in SystemVerilog. It includes the RV64IMAFD extensions, providing integer, multiplication/division, atomic, floating-point, and double-precision floating-point

# Features

# Directory Structure
- **document:** Contains all files related to the documentation of the RTL.
- **include:** Contains all headers, macros, constants, packages, etc., used in both RTL and TB.
- **source:** Contains the SystemVerilog RTL files.
- **test:** Contains SystemVerilog testbench and it's relevant files.
- **submodules:** Contains other git repositories as submodule to this repository.
- **build:** Auto generated. Contains builds of simulation.
- **log:** Auto generated. Contains logs of simulation.

# Module List
[click here to see the list of modules in this repository](./modules.md)

# Coding Guide Lines ([verible-verilog-lint](https://github.com/chipsalliance/verible))
[click here to see the coding guide lines](./coding_guideline.md)
