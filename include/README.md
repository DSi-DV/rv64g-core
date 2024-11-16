# README
- This folder will contains all the SystemVerilog header files, package, macros, etc.
- Please make subfolders as required.
- Please put all header contents inside compiler directive: not defined condition. Please use `ifndef`, `define` & `endif` for each file. For example, for file `abcd_efgh.xyz`, name the directive as ABCD_EFGH_XYZ__
  ```SV
  `ifndef ABCD_EFGH_XYZ__
  `define ABCD_EFGH_XYZ__

    // CONTENTS HERE

  `endif
  ```
