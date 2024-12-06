/*
Author : Foez Ahmed (https://github.com/foez-ahmed)
This file is part of DSInnovators:rv64g-core
Copyright (c) 2024 DSInnovators
Licensed under the MIT License
See LICENSE file in the project root for full license information
*/

`ifndef RV64G_PKG_SV__
`define RV64G_PKG_SV__ 0

package rv64g_pkg;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PARAMETERS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  parameter int XLEN = 64;
  parameter int FLEN = 64;

  parameter int NUM_GPR = 32;
  parameter int NUM_FPR = 32;

  parameter int NUM_REGS = NUM_GPR + NUM_FPR;

  ////////////////////////////////////////////////
  // RV64G_INSTR_LAUNCHER
  ////////////////////////////////////////////////

  parameter int NUM_OUTSTANDING = 7;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ISA
  //////////////////////////////////////////////////////////////////////////////////////////////////

  parameter bit ____ = 0;  // NOT TO KEEP
  parameter bit KEEP = 1;  // TO KEEP

  typedef enum logic [3:0] {
    NONE,  // NO IMMEDIATE
    AIMM,  // SHIFT AMOUNT
    BIMM,  // BTYPE INSTRUCTION IMMEDIATE
    CIMM,  // CSR INSTRUCTION IMMEDIATE
    IIMM,  // ITYPE INSTRUCTION IMMEDIATE
    JIMM,  // JTYPE INSTRUCTION IMMEDIATE
    RIMM,  // FLOATING ROUND MODE IMMEDIATE
    SIMM,  // RTYPE INSTRUCTION IMMEDIATE
    TIMM,  // ATOMICS IMMEDIATE
    UIMM   // UTYPE INSTRUCTION IMMEDIATE
  } imm_src_t;

  typedef enum logic [7:0] {
    LUI,
    AUIPC,
    JAL,
    JALR,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    LB,
    LH,
    LW,
    LBU,
    LHU,
    SB,
    SH,
    SW,
    ADDI,
    SLTI,
    SLTIU,
    XORI,
    ORI,
    ANDI,
    SLLI,
    SRLI,
    SRAI,
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND,
    FENCE,
    FENCE_TSO,
    PAUSE,
    ECALL,
    EBREAK,
    LWU,
    LD,
    SD,
    ADDIW,
    SLLIW,
    SRLIW,
    SRAIW,
    ADDW,
    SUBW,
    SLLW,
    SRLW,
    SRAW,
    CSRRW,
    CSRRS,
    CSRRC,
    CSRRWI,
    CSRRSI,
    CSRRCI,
    MUL,
    MULH,
    MULHSU,
    MULHU,
    DIV,
    DIVU,
    REM,
    REMU,
    MULW,
    DIVW,
    DIVUW,
    REMW,
    REMUW,
    LR_W,
    SC_W,
    AMOSWAP_W,
    AMOADD_W,
    AMOXOR_W,
    AMOAND_W,
    AMOOR_W,
    AMOMIN_W,
    AMOMAX_W,
    AMOMINU_W,
    AMOMAXU_W,
    LR_D,
    SC_D,
    AMOSWAP_D,
    AMOADD_D,
    AMOXOR_D,
    AMOAND_D,
    AMOOR_D,
    AMOMIN_D,
    AMOMAX_D,
    AMOMINU_D,
    AMOMAXU_D,
    FLW,
    FSW,
    FMADD_S,
    FMSUB_S,
    FNMSUB_S,
    FNMADD_S,
    FADD_S,
    FSUB_S,
    FMUL_S,
    FDIV_S,
    FSQRT_S,
    FSGNJ_S,
    FSGNJN_S,
    FSGNJX_S,
    FMIN_S,
    FMAX_S,
    FCVT_W_S,
    FCVT_WU_S,
    FMV_X_W,
    FEQ_S,
    FLT_S,
    FLE_S,
    FCLASS_S,
    FCVT_S_W,
    FCVT_S_WU,
    FMV_W_X,
    FCVT_L_S,
    FCVT_LU_S,
    FCVT_S_L,
    FCVT_S_LU,
    FLD,
    FSD,
    FMADD_D,
    FMSUB_D,
    FNMSUB_D,
    FNMADD_D,
    FADD_D,
    FSUB_D,
    FMUL_D,
    FDIV_D,
    FSQRT_D,
    FSGNJ_D,
    FSGNJN_D,
    FSGNJX_D,
    FMIN_D,
    FMAX_D,
    FCVT_S_D,
    FCVT_D_S,
    FEQ_D,
    FLT_D,
    FLE_D,
    FCLASS_D,
    FCVT_W_D,
    FCVT_WU_D,
    FCVT_D_W,
    FCVT_D_WU,
    FCVT_L_D,
    FCVT_LU_D,
    FMV_X_D,
    FCVT_D_L,
    FCVT_D_LU,
    FMV_D_X,
    INVALID   = 'hFF
  } func_t;

  func_t functions;

  parameter int TOTAL_FUNCS = functions.num() - 1;

  typedef enum logic [19:0] {
    //             19:16 15    14    13    12    11    10    9     8     7:0
    //             IMM_  jump  frs3  frs2  frs1  frd_  xrs2  xrs1  xrd_, Function
    i_LUI       = {UIMM, ____, ____, ____, ____, ____, ____, ____, KEEP, LUI},
    i_AUIPC     = {UIMM, ____, ____, ____, ____, ____, ____, ____, KEEP, AUIPC},
    i_JAL       = {JIMM, KEEP, ____, ____, ____, ____, ____, ____, KEEP, JAL},
    i_JALR      = {IIMM, KEEP, ____, ____, ____, ____, ____, KEEP, KEEP, JALR},
    i_BEQ       = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BEQ},
    i_BNE       = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BNE},
    i_BLT       = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BLT},
    i_BGE       = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BGE},
    i_BLTU      = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BLTU},
    i_BGEU      = {BIMM, KEEP, ____, ____, ____, ____, KEEP, KEEP, ____, BGEU},
    i_LB        = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LB},
    i_LH        = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LH},
    i_LW        = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LW},
    i_LBU       = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LBU},
    i_LHU       = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LHU},
    i_SB        = {SIMM, ____, ____, ____, ____, ____, KEEP, KEEP, ____, SB},
    i_SH        = {SIMM, ____, ____, ____, ____, ____, KEEP, KEEP, ____, SH},
    i_SW        = {SIMM, ____, ____, ____, ____, ____, KEEP, KEEP, ____, SW},
    i_ADDI      = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, ADDI},
    i_SLTI      = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SLTI},
    i_SLTIU     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SLTIU},
    i_XORI      = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, XORI},
    i_ORI       = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, ORI},
    i_ANDI      = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, ANDI},
    i_SLLI      = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SLLI},
    i_SRLI      = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SRLI},
    i_SRAI      = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SRAI},
    i_ADD       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, ADD},
    i_SUB       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SUB},
    i_SLL       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SLL},
    i_SLT       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SLT},
    i_SLTU      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SLTU},
    i_XOR       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, XOR},
    i_SRL       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SRL},
    i_SRA       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SRA},
    i_OR        = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, OR},
    i_AND       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AND},
    i_FENCE     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, FENCE},
    i_FENCE_TSO = {IIMM, ____, ____, ____, ____, ____, ____, ____, ____, FENCE_TSO},
    i_PAUSE     = {IIMM, ____, ____, ____, ____, ____, ____, ____, ____, PAUSE},
    i_ECALL     = {IIMM, ____, ____, ____, ____, ____, ____, ____, ____, ECALL},
    i_EBREAK    = {IIMM, ____, ____, ____, ____, ____, ____, ____, ____, EBREAK},
    i_LWU       = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LWU},
    i_LD        = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LD},
    i_SD        = {SIMM, ____, ____, ____, ____, ____, KEEP, KEEP, ____, SD},
    i_ADDIW     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, ADDIW},
    i_SLLIW     = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SLLIW},
    i_SRLIW     = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SRLIW},
    i_SRAIW     = {AIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, SRAIW},
    i_ADDW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, ADDW},
    i_SUBW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SUBW},
    i_SLLW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SLLW},
    i_SRLW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SRLW},
    i_SRAW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SRAW},
    i_CSRRW     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, CSRRW},
    i_CSRRS     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, CSRRS},
    i_CSRRC     = {IIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, CSRRC},
    i_CSRRWI    = {CIMM, ____, ____, ____, ____, ____, ____, ____, KEEP, CSRRWI},
    i_CSRRSI    = {CIMM, ____, ____, ____, ____, ____, ____, ____, KEEP, CSRRSI},
    i_CSRRCI    = {CIMM, ____, ____, ____, ____, ____, ____, ____, KEEP, CSRRCI},
    i_MUL       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, MUL},
    i_MULH      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, MULH},
    i_MULHSU    = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, MULHSU},
    i_MULHU     = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, MULHU},
    i_DIV       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, DIV},
    i_DIVU      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, DIVU},
    i_REM       = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, REM},
    i_REMU      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, REMU},
    i_MULW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, MULW},
    i_DIVW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, DIVW},
    i_DIVUW     = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, DIVUW},
    i_REMW      = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, REMW},
    i_REMUW     = {NONE, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, REMUW},
    i_LR_W      = {TIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LR_W},
    i_SC_W      = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SC_W},
    i_AMOSWAP_W = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOSWAP_W},
    i_AMOADD_W  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOADD_W},
    i_AMOXOR_W  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOXOR_W},
    i_AMOAND_W  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOAND_W},
    i_AMOOR_W   = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOOR_W},
    i_AMOMIN_W  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMIN_W},
    i_AMOMAX_W  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMAX_W},
    i_AMOMINU_W = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMINU_W},
    i_AMOMAXU_W = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMAXU_W},
    i_LR_D      = {TIMM, ____, ____, ____, ____, ____, ____, KEEP, KEEP, LR_D},
    i_SC_D      = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, SC_D},
    i_AMOSWAP_D = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOSWAP_D},
    i_AMOADD_D  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOADD_D},
    i_AMOXOR_D  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOXOR_D},
    i_AMOAND_D  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOAND_D},
    i_AMOOR_D   = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOOR_D},
    i_AMOMIN_D  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMIN_D},
    i_AMOMAX_D  = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMAX_D},
    i_AMOMINU_D = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMINU_D},
    i_AMOMAXU_D = {TIMM, ____, ____, ____, ____, ____, KEEP, KEEP, KEEP, AMOMAXU_D},
    i_FLW       = {IIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FLW},
    i_FSW       = {SIMM, ____, ____, ____, KEEP, ____, ____, KEEP, ____, FSW},
    i_FMADD_S   = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FMADD_S},
    i_FMSUB_S   = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FMSUB_S},
    i_FNMSUB_S  = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FNMSUB_S},
    i_FNMADD_S  = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FNMADD_S},
    i_FADD_S    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FADD_S},
    i_FSUB_S    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSUB_S},
    i_FMUL_S    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMUL_S},
    i_FDIV_S    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FDIV_S},
    i_FSQRT_S   = {RIMM, ____, ____, ____, KEEP, KEEP, ____, ____, ____, FSQRT_S},
    i_FSGNJ_S   = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJ_S},
    i_FSGNJN_S  = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJN_S},
    i_FSGNJX_S  = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJX_S},
    i_FMIN_S    = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMIN_S},
    i_FMAX_S    = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMAX_S},
    i_FCVT_W_S  = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_W_S},
    i_FCVT_WU_S = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_WU_S},
    i_FMV_X_W   = {NONE, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FMV_X_W},
    i_FEQ_S     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FEQ_S},
    i_FLT_S     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FLT_S},
    i_FLE_S     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FLE_S},
    i_FCLASS_S  = {NONE, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCLASS_S},
    i_FCVT_S_W  = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_S_W},
    i_FCVT_S_WU = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_S_WU},
    i_FMV_W_X   = {NONE, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FMV_W_X},
    i_FCVT_L_S  = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_L_S},
    i_FCVT_LU_S = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_LU_S},
    i_FCVT_S_L  = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_S_L},
    i_FCVT_S_LU = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_S_LU},
    i_FLD       = {IIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FLD},
    i_FSD       = {SIMM, ____, ____, ____, KEEP, ____, ____, KEEP, ____, FSD},
    i_FMADD_D   = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FMADD_D},
    i_FMSUB_D   = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FMSUB_D},
    i_FNMSUB_D  = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FNMSUB_D},
    i_FNMADD_D  = {RIMM, ____, KEEP, KEEP, KEEP, KEEP, ____, ____, ____, FNMADD_D},
    i_FADD_D    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FADD_D},
    i_FSUB_D    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSUB_D},
    i_FMUL_D    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMUL_D},
    i_FDIV_D    = {RIMM, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FDIV_D},
    i_FSQRT_D   = {RIMM, ____, ____, ____, KEEP, KEEP, ____, ____, ____, FSQRT_D},
    i_FSGNJ_D   = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJ_D},
    i_FSGNJN_D  = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJN_D},
    i_FSGNJX_D  = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FSGNJX_D},
    i_FMIN_D    = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMIN_D},
    i_FMAX_D    = {NONE, ____, ____, KEEP, KEEP, KEEP, ____, ____, ____, FMAX_D},
    i_FCVT_S_D  = {RIMM, ____, ____, ____, KEEP, KEEP, ____, ____, ____, FCVT_S_D},
    i_FCVT_D_S  = {RIMM, ____, ____, ____, KEEP, KEEP, ____, ____, ____, FCVT_D_S},
    i_FEQ_D     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FEQ_D},
    i_FLT_D     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FLT_D},
    i_FLE_D     = {NONE, ____, ____, KEEP, KEEP, ____, ____, ____, KEEP, FLE_D},
    i_FCLASS_D  = {NONE, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCLASS_D},
    i_FCVT_W_D  = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_W_D},
    i_FCVT_WU_D = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_WU_D},
    i_FCVT_D_W  = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_D_W},
    i_FCVT_D_WU = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_D_WU},
    i_FCVT_L_D  = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_L_D},
    i_FCVT_LU_D = {RIMM, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FCVT_LU_D},
    i_FMV_X_D   = {NONE, ____, ____, ____, KEEP, ____, ____, ____, KEEP, FMV_X_D},
    i_FCVT_D_L  = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_D_L},
    i_FCVT_D_LU = {RIMM, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FCVT_D_LU},
    i_FMV_D_X   = {NONE, ____, ____, ____, ____, KEEP, ____, KEEP, ____, FMV_D_X},
    i_INVALID   = {NONE, ____, ____, ____, ____, ____, ____, ____, ____, INVALID}
    //             IMM_  jump  frs3  frs2  frs1  frd_  xrs2  xrs1  xrd_, Function
    //             19:16 15    14    13    12    11    10    9     8     7:0
  } intr_func_t;

  typedef struct packed {

    // The `func` field enumerates the function that the current instruction.
    func_t func;

    // The `rd` is the destination register ant the `rs1`, `rs2` & `rs3` are the source registers.
    // An offset of 32 is added for the floating point registers' address.
    logic [$clog2(NUM_REGS)-1:0] rd;
    logic [$clog2(NUM_REGS)-1:0] rs1;
    logic [$clog2(NUM_REGS)-1:0] rs2;
    logic [$clog2(NUM_REGS)-1:0] rs3;

    // The `imm` has multi-purpose such signed/unsigned immediate, shift, csr_addr, etc. based on
    // the `func`. -------- imm:64 / {fm:4,pred:4,succ:4} / shamt:6 / {uimm:5,csr:12} / rm / {aq, rl}
    logic [XLEN-1:0] imm;

    // The `pc` hold's the physical address of the current instruction.
    logic [XLEN-1:0] pc;

    // The `jump` field is set high when the current instruction can cause branch/jump.
    logic jump;

    // The `reg_req` field is a flag that indicates the registers that are required for the current
    // instruction
    logic [NUM_REGS-1:0] reg_req;

  } decoded_instr_t;

endpackage

`endif
