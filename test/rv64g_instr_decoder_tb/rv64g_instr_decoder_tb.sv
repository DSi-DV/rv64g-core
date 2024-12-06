/*
Description
Author : Subhan Zawad Bihan (https://github.com/SubhanBihan)
Co-Author : S. M. Tahmeed Reza (https://github.com/tahmeedKENJI)
This file is part of DSInnovators:rv64g-core
Copyright (c) 2024 DSInnovators
Licensed under the MIT License
See LICENSE file in the project root for full license information
*/

module rv64g_instr_decoder_tb;

  //`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
  `include "vip/tb_ess.sv"
  `include "rv64g_pkg.sv"

  import rv64g_pkg::*;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  localparam int Clen = 32;
  localparam int NumInstr = 158;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // generates static task start_clk_i with tHigh:4ns tLow:6ns
  `CREATE_CLK(clk_i, 2ns, 2ns)

  logic [Clen-1:0] code_i;
  decoded_instr_t cmd_o;
  logic [XLEN-1:0] pc_i;
  decoded_instr_t exp_cmd_o;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  bit in_out_ok;  // Flag to check input-output match
  int tx_success;  // Counter for successful transfers

  logic instr_check[256];
  int count = 0;

  logic [11:0] reg_state;
  imm_src_t imm_src_infer;
  logic [XLEN-1:0] stand_imm; // stand-in immediate

  event e_all_instr_checked;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // update the program counter
  always_comb begin : pc
    exp_cmd_o.pc = pc_i;
  end

  // determine the instruction
  always_comb begin : func
    casez (code_i)
      32'bzzzzzzzzzzzzzzzzzzzzzzzzz0010111: exp_cmd_o.func = AUIPC;
      32'bzzzzzzzzzzzzzzzzzzzzzzzzz1101111: exp_cmd_o.func = JAL;
      32'bzzzzzzzzzzzzzzzzz000zzzzz1100111: exp_cmd_o.func = JALR;
      32'bzzzzzzzzzzzzzzzzzzzzzzzzz0110111: exp_cmd_o.func = LUI;
      32'bzzzzzzzzzzzzzzzzz000zzzzz1100011: exp_cmd_o.func = BEQ;
      32'bzzzzzzzzzzzzzzzzz001zzzzz1100011: exp_cmd_o.func = BNE;
      32'bzzzzzzzzzzzzzzzzz100zzzzz1100011: exp_cmd_o.func = BLT;
      32'bzzzzzzzzzzzzzzzzz101zzzzz1100011: exp_cmd_o.func = BGE;
      32'bzzzzzzzzzzzzzzzzz110zzzzz1100011: exp_cmd_o.func = BLTU;
      32'bzzzzzzzzzzzzzzzzz111zzzzz1100011: exp_cmd_o.func = BGEU;
      32'bzzzzzzzzzzzzzzzzz000zzzzz0000011: exp_cmd_o.func = LB;
      32'bzzzzzzzzzzzzzzzzz001zzzzz0000011: exp_cmd_o.func = LH;
      32'bzzzzzzzzzzzzzzzzz010zzzzz0000011: exp_cmd_o.func = LW;
      32'bzzzzzzzzzzzzzzzzz100zzzzz0000011: exp_cmd_o.func = LBU;
      32'bzzzzzzzzzzzzzzzzz101zzzzz0000011: exp_cmd_o.func = LHU;
      32'bzzzzzzzzzzzzzzzzz000zzzzz0100011: exp_cmd_o.func = SB;
      32'bzzzzzzzzzzzzzzzzz001zzzzz0100011: exp_cmd_o.func = SH;
      32'bzzzzzzzzzzzzzzzzz010zzzzz0100011: exp_cmd_o.func = SW;
      32'bzzzzzzzzzzzzzzzzz000zzzzz0010011: exp_cmd_o.func = ADDI;
      32'bzzzzzzzzzzzzzzzzz010zzzzz0010011: exp_cmd_o.func = SLTI;
      32'bzzzzzzzzzzzzzzzzz011zzzzz0010011: exp_cmd_o.func = SLTIU;
      32'bzzzzzzzzzzzzzzzzz100zzzzz0010011: exp_cmd_o.func = XORI;
      32'bzzzzzzzzzzzzzzzzz110zzzzz0010011: exp_cmd_o.func = ORI;
      32'bzzzzzzzzzzzzzzzzz111zzzzz0010011: exp_cmd_o.func = ANDI;
      32'b0000000zzzzzzzzzz000zzzzz0110011: exp_cmd_o.func = ADD;
      32'b0100000zzzzzzzzzz000zzzzz0110011: exp_cmd_o.func = SUB;
      32'b0000000zzzzzzzzzz001zzzzz0110011: exp_cmd_o.func = SLL;
      32'b0000000zzzzzzzzzz010zzzzz0110011: exp_cmd_o.func = SLT;
      32'b0000000zzzzzzzzzz011zzzzz0110011: exp_cmd_o.func = SLTU;
      32'b0000000zzzzzzzzzz100zzzzz0110011: exp_cmd_o.func = XOR;
      32'b0000000zzzzzzzzzz101zzzzz0110011: exp_cmd_o.func = SRL;
      32'b0100000zzzzzzzzzz101zzzzz0110011: exp_cmd_o.func = SRA;
      32'b0000000zzzzzzzzzz110zzzzz0110011: exp_cmd_o.func = OR;
      32'b0000000zzzzzzzzzz111zzzzz0110011: exp_cmd_o.func = AND;
      32'bzzzzzzzzzzzzzzzzz000zzzzz0001111: exp_cmd_o.func = FENCE;
      32'b10000011001100000000000000001111: exp_cmd_o.func = FENCE_TSO;
      32'b00000001000000000000000000001111: exp_cmd_o.func = PAUSE;
      32'b00000000000000000000000001110011: exp_cmd_o.func = ECALL;
      32'b00000000000100000000000001110011: exp_cmd_o.func = EBREAK;
      32'bzzzzzzzzzzzzzzzzz110zzzzz0000011: exp_cmd_o.func = LWU;
      32'bzzzzzzzzzzzzzzzzz011zzzzz0000011: exp_cmd_o.func = LD;
      32'bzzzzzzzzzzzzzzzzz011zzzzz0100011: exp_cmd_o.func = SD;
      32'b000000zzzzzzzzzzz001zzzzz0010011: exp_cmd_o.func = SLLI;
      32'b000000zzzzzzzzzzz101zzzzz0010011: exp_cmd_o.func = SRLI;
      32'b010000zzzzzzzzzzz101zzzzz0010011: exp_cmd_o.func = SRAI;
      32'bzzzzzzzzzzzzzzzzz000zzzzz0011011: exp_cmd_o.func = ADDIW;
      32'b0000000zzzzzzzzzz001zzzzz0011011: exp_cmd_o.func = SLLIW;
      32'b0000000zzzzzzzzzz101zzzzz0011011: exp_cmd_o.func = SRLIW;
      32'b0100000zzzzzzzzzz101zzzzz0011011: exp_cmd_o.func = SRAIW;
      32'b0000000zzzzzzzzzz000zzzzz0111011: exp_cmd_o.func = ADDW;
      32'b0100000zzzzzzzzzz000zzzzz0111011: exp_cmd_o.func = SUBW;
      32'b0000000zzzzzzzzzz001zzzzz0111011: exp_cmd_o.func = SLLW;
      32'b0000000zzzzzzzzzz101zzzzz0111011: exp_cmd_o.func = SRLW;
      32'b0100000zzzzzzzzzz101zzzzz0111011: exp_cmd_o.func = SRAW;
      32'bzzzzzzzzzzzzzzzzz001zzzzz1110011: exp_cmd_o.func = CSRRW;
      32'bzzzzzzzzzzzzzzzzz010zzzzz1110011: exp_cmd_o.func = CSRRS;
      32'bzzzzzzzzzzzzzzzzz011zzzzz1110011: exp_cmd_o.func = CSRRC;
      32'bzzzzzzzzzzzzzzzzz101zzzzz1110011: exp_cmd_o.func = CSRRWI;
      32'bzzzzzzzzzzzzzzzzz110zzzzz1110011: exp_cmd_o.func = CSRRSI;
      32'bzzzzzzzzzzzzzzzzz111zzzzz1110011: exp_cmd_o.func = CSRRCI;
      32'b0000001zzzzzzzzzz000zzzzz0110011: exp_cmd_o.func = MUL;
      32'b0000001zzzzzzzzzz001zzzzz0110011: exp_cmd_o.func = MULH;
      32'b0000001zzzzzzzzzz010zzzzz0110011: exp_cmd_o.func = MULHSU;
      32'b0000001zzzzzzzzzz011zzzzz0110011: exp_cmd_o.func = MULHU;
      32'b0000001zzzzzzzzzz100zzzzz0110011: exp_cmd_o.func = DIV;
      32'b0000001zzzzzzzzzz101zzzzz0110011: exp_cmd_o.func = DIVU;
      32'b0000001zzzzzzzzzz110zzzzz0110011: exp_cmd_o.func = REM;
      32'b0000001zzzzzzzzzz111zzzzz0110011: exp_cmd_o.func = REMU;
      32'b0000001zzzzzzzzzz000zzzzz0111011: exp_cmd_o.func = MULW;
      32'b0000001zzzzzzzzzz100zzzzz0111011: exp_cmd_o.func = DIVW;
      32'b0000001zzzzzzzzzz101zzzzz0111011: exp_cmd_o.func = DIVUW;
      32'b0000001zzzzzzzzzz110zzzzz0111011: exp_cmd_o.func = REMW;
      32'b0000001zzzzzzzzzz111zzzzz0111011: exp_cmd_o.func = REMUW;
      32'b00010zz00000zzzzz010zzzzz0101111: exp_cmd_o.func = LR_W;
      32'b00011zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = SC_W;
      32'b00001zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOSWAP_W;
      32'b00000zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOADD_W;
      32'b00100zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOXOR_W;
      32'b01100zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOAND_W;
      32'b01000zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOOR_W;
      32'b10000zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOMIN_W;
      32'b10100zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOMAX_W;
      32'b11000zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOMINU_W;
      32'b11100zzzzzzzzzzzz010zzzzz0101111: exp_cmd_o.func = AMOMAXU_W;
      32'b00010zz00000zzzzz011zzzzz0101111: exp_cmd_o.func = LR_D;
      32'b00011zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = SC_D;
      32'b00001zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOSWAP_D;
      32'b00000zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOADD_D;
      32'b00100zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOXOR_D;
      32'b01100zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOAND_D;
      32'b01000zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOOR_D;
      32'b10000zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOMIN_D;
      32'b10100zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOMAX_D;
      32'b11000zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOMINU_D;
      32'b11100zzzzzzzzzzzz011zzzzz0101111: exp_cmd_o.func = AMOMAXU_D;
      32'bzzzzzzzzzzzzzzzzz010zzzzz0000111: exp_cmd_o.func = FLW;
      32'bzzzzzzzzzzzzzzzzz010zzzzz0100111: exp_cmd_o.func = FSW;
      32'bzzzzz00zzzzzzzzzzzzzzzzzz1000011: exp_cmd_o.func = FMADD_S;
      32'bzzzzz00zzzzzzzzzzzzzzzzzz1000111: exp_cmd_o.func = FMSUB_S;
      32'bzzzzz00zzzzzzzzzzzzzzzzzz1001011: exp_cmd_o.func = FNMSUB_S;
      32'bzzzzz00zzzzzzzzzzzzzzzzzz1001111: exp_cmd_o.func = FNMADD_S;
      32'b0000000zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FADD_S;
      32'b0000100zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FSUB_S;
      32'b0001000zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FMUL_S;
      32'b0001100zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FDIV_S;
      32'b010110000000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FSQRT_S;
      32'b0010000zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FSGNJ_S;
      32'b0010000zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FSGNJN_S;
      32'b0010000zzzzzzzzzz010zzzzz1010011: exp_cmd_o.func = FSGNJX_S;
      32'b0010100zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FMIN_S;
      32'b0010100zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FMAX_S;
      32'b110000000000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_W_S;
      32'b110000000001zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_WU_S;
      32'b111000000000zzzzz000zzzzz1010011: exp_cmd_o.func = FMV_X_W;
      32'b1010000zzzzzzzzzz010zzzzz1010011: exp_cmd_o.func = FEQ_S;
      32'b1010000zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FLT_S;
      32'b1010000zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FLE_S;
      32'b111000000000zzzzz001zzzzz1010011: exp_cmd_o.func = FCLASS_S;
      32'b110100000000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_S_W;
      32'b110100000001zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_S_WU;
      32'b111100000000zzzzz000zzzzz1010011: exp_cmd_o.func = FMV_W_X;
      32'b110000000010zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_L_S;
      32'b110000000011zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_LU_S;
      32'b110100000010zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_S_L;
      32'b110100000011zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_S_LU;
      32'bzzzzzzzzzzzzzzzzz011zzzzz0000111: exp_cmd_o.func = FLD;
      32'bzzzzzzzzzzzzzzzzz011zzzzz0100111: exp_cmd_o.func = FSD;
      32'bzzzzz01zzzzzzzzzzzzzzzzzz1000011: exp_cmd_o.func = FMADD_D;
      32'bzzzzz01zzzzzzzzzzzzzzzzzz1000111: exp_cmd_o.func = FMSUB_D;
      32'bzzzzz01zzzzzzzzzzzzzzzzzz1001011: exp_cmd_o.func = FNMSUB_D;
      32'bzzzzz01zzzzzzzzzzzzzzzzzz1001111: exp_cmd_o.func = FNMADD_D;
      32'b0000001zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FADD_D;
      32'b0000101zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FSUB_D;
      32'b0001001zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FMUL_D;
      32'b0001101zzzzzzzzzzzzzzzzzz1010011: exp_cmd_o.func = FDIV_D;
      32'b010110100000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FSQRT_D;
      32'b0010001zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FSGNJ_D;
      32'b0010001zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FSGNJN_D;
      32'b0010001zzzzzzzzzz010zzzzz1010011: exp_cmd_o.func = FSGNJX_D;
      32'b0010101zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FMIN_D;
      32'b0010101zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FMAX_D;
      32'b010000000001zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_S_D;
      32'b010000100000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_D_S;
      32'b1010001zzzzzzzzzz010zzzzz1010011: exp_cmd_o.func = FEQ_D;
      32'b1010001zzzzzzzzzz001zzzzz1010011: exp_cmd_o.func = FLT_D;
      32'b1010001zzzzzzzzzz000zzzzz1010011: exp_cmd_o.func = FLE_D;
      32'b111000100000zzzzz001zzzzz1010011: exp_cmd_o.func = FCLASS_D;
      32'b110000100000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_W_D;
      32'b110000100001zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_WU_D;
      32'b110100100000zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_D_W;
      32'b110100100001zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_D_WU;
      32'b110000100010zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_L_D;
      32'b110000100011zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_LU_D;
      32'b111000100000zzzzz000zzzzz1010011: exp_cmd_o.func = FMV_X_D;
      32'b110100100010zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_D_L;
      32'b110100100011zzzzzzzzzzzzz1010011: exp_cmd_o.func = FCVT_D_LU;
      32'b111100100000zzzzz000zzzzz1010011: exp_cmd_o.func = FMV_D_X;
      default: exp_cmd_o.func = INVALID;
    endcase
  end

  // check for jump condition
  always_comb begin : jump
    string func_name = exp_cmd_o.func.name();
    exp_cmd_o.jump = (func_name[0] == "J") | (func_name[0] == "B");
  end

  // determine register state for each instruction
  always_comb begin : reg_state
    unique case (exp_cmd_o.func)
      LUI:       reg_state = 12'o1000;
      AUIPC:     reg_state = 12'o1000;
      JAL:       reg_state = 12'o1000;
      JALR:      reg_state = 12'o1100;
      BEQ:       reg_state = 12'o0110;
      BNE:       reg_state = 12'o0110;
      BLT:       reg_state = 12'o0110;
      BGE:       reg_state = 12'o0110;
      BLTU:      reg_state = 12'o0110;
      BGEU:      reg_state = 12'o0110;
      LB:        reg_state = 12'o1100;
      LH:        reg_state = 12'o1100;
      LW:        reg_state = 12'o1100;
      LBU:       reg_state = 12'o1100;
      LHU:       reg_state = 12'o1100;
      SB:        reg_state = 12'o0110;
      SH:        reg_state = 12'o0110;
      SW:        reg_state = 12'o0110;
      ADDI:      reg_state = 12'o1100;
      SLTI:      reg_state = 12'o1100;
      SLTIU:     reg_state = 12'o1100;
      XORI:      reg_state = 12'o1100;
      ORI:       reg_state = 12'o1100;
      ANDI:      reg_state = 12'o1100;
      SLLI:      reg_state = 12'o1100;
      SRLI:      reg_state = 12'o1100;
      SRAI:      reg_state = 12'o1100;
      ADD:       reg_state = 12'o1110;
      SUB:       reg_state = 12'o1110;
      SLL:       reg_state = 12'o1110;
      SLT:       reg_state = 12'o1110;
      SLTU:      reg_state = 12'o1110;
      XOR:       reg_state = 12'o1110;
      SRL:       reg_state = 12'o1110;
      SRA:       reg_state = 12'o1110;
      OR:        reg_state = 12'o1110;
      AND:       reg_state = 12'o1110;
      FENCE:     reg_state = 12'o1100;
      FENCE_TSO: reg_state = 12'o0000;
      PAUSE:     reg_state = 12'o0000;
      ECALL:     reg_state = 12'o0000;
      EBREAK:    reg_state = 12'o0000;
      LWU:       reg_state = 12'o1100;
      LD:        reg_state = 12'o1100;
      SD:        reg_state = 12'o0110;
      ADDIW:     reg_state = 12'o1100;
      SLLIW:     reg_state = 12'o1100;
      SRLIW:     reg_state = 12'o1100;
      SRAIW:     reg_state = 12'o1100;
      ADDW:      reg_state = 12'o1110;
      SUBW:      reg_state = 12'o1110;
      SLLW:      reg_state = 12'o1110;
      SRLW:      reg_state = 12'o1110;
      SRAW:      reg_state = 12'o1110;
      CSRRW:     reg_state = 12'o1100;
      CSRRS:     reg_state = 12'o1100;
      CSRRC:     reg_state = 12'o1100;
      CSRRWI:    reg_state = 12'o1000;
      CSRRSI:    reg_state = 12'o1000;
      CSRRCI:    reg_state = 12'o1000;
      MUL:       reg_state = 12'o1110;
      MULH:      reg_state = 12'o1110;
      MULHSU:    reg_state = 12'o1110;
      MULHU:     reg_state = 12'o1110;
      DIV:       reg_state = 12'o1110;
      DIVU:      reg_state = 12'o1110;
      REM:       reg_state = 12'o1110;
      REMU:      reg_state = 12'o1110;
      MULW:      reg_state = 12'o1110;
      DIVW:      reg_state = 12'o1110;
      DIVUW:     reg_state = 12'o1110;
      REMW:      reg_state = 12'o1110;
      REMUW:     reg_state = 12'o1110;
      LR_W:      reg_state = 12'o1100;
      SC_W:      reg_state = 12'o1110;
      AMOSWAP_W: reg_state = 12'o1110;
      AMOADD_W:  reg_state = 12'o1110;
      AMOXOR_W:  reg_state = 12'o1110;
      AMOAND_W:  reg_state = 12'o1110;
      AMOOR_W:   reg_state = 12'o1110;
      AMOMIN_W:  reg_state = 12'o1110;
      AMOMAX_W:  reg_state = 12'o1110;
      AMOMINU_W: reg_state = 12'o1110;
      AMOMAXU_W: reg_state = 12'o1110;
      LR_D:      reg_state = 12'o1100;
      SC_D:      reg_state = 12'o1110;
      AMOSWAP_D: reg_state = 12'o1110;
      AMOADD_D:  reg_state = 12'o1110;
      AMOXOR_D:  reg_state = 12'o1110;
      AMOAND_D:  reg_state = 12'o1110;
      AMOOR_D:   reg_state = 12'o1110;
      AMOMIN_D:  reg_state = 12'o1110;
      AMOMAX_D:  reg_state = 12'o1110;
      AMOMINU_D: reg_state = 12'o1110;
      AMOMAXU_D: reg_state = 12'o1110;
      FLW:       reg_state = 12'o2100;
      FSW:       reg_state = 12'o0120;
      FADD_S:    reg_state = 12'o2220;
      FSUB_S:    reg_state = 12'o2220;
      FMUL_S:    reg_state = 12'o2220;
      FDIV_S:    reg_state = 12'o2220;
      FSQRT_S:   reg_state = 12'o2200;
      FMIN_S:    reg_state = 12'o2220;
      FMAX_S:    reg_state = 12'o2220;
      FMADD_S:   reg_state = 12'o2222;
      FMSUB_S:   reg_state = 12'o2222;
      FNMADD_S:  reg_state = 12'o2222;
      FNMSUB_S:  reg_state = 12'o2222;
      FCVT_W_S:  reg_state = 12'o1200;
      FCVT_WU_S: reg_state = 12'o1200;
      FCVT_L_S:  reg_state = 12'o1200;
      FCVT_LU_S: reg_state = 12'o1200;
      FCVT_S_W:  reg_state = 12'o2100;
      FCVT_S_WU: reg_state = 12'o2100;
      FCVT_S_L:  reg_state = 12'o2100;
      FCVT_S_LU: reg_state = 12'o2100;
      FSGNJ_S:   reg_state = 12'o2220;
      FSGNJN_S:  reg_state = 12'o2220;
      FSGNJX_S:  reg_state = 12'o2220;
      FMV_X_W:   reg_state = 12'o1200;
      FMV_W_X:   reg_state = 12'o2100;
      FEQ_S:     reg_state = 12'o1220;
      FLT_S:     reg_state = 12'o1220;
      FLE_S:     reg_state = 12'o1220;
      FCLASS_S:  reg_state = 12'o1200;
      FLD:       reg_state = 12'o2100;
      FSD:       reg_state = 12'o0120;
      FADD_D:    reg_state = 12'o2220;
      FSUB_D:    reg_state = 12'o2220;
      FMUL_D:    reg_state = 12'o2220;
      FDIV_D:    reg_state = 12'o2220;
      FSQRT_D:   reg_state = 12'o2200;
      FMIN_D:    reg_state = 12'o2220;
      FMAX_D:    reg_state = 12'o2220;
      FMADD_D:   reg_state = 12'o2222;
      FMSUB_D:   reg_state = 12'o2222;
      FNMADD_D:  reg_state = 12'o2222;
      FNMSUB_D:  reg_state = 12'o2222;
      FCVT_W_D:  reg_state = 12'o1200;
      FCVT_WU_D: reg_state = 12'o1200;
      FCVT_L_D:  reg_state = 12'o1200;
      FCVT_LU_D: reg_state = 12'o1200;
      FCVT_D_W:  reg_state = 12'o2100;
      FCVT_D_WU: reg_state = 12'o2100;
      FCVT_D_L:  reg_state = 12'o2100;
      FCVT_D_LU: reg_state = 12'o2100;
      FCVT_S_D:  reg_state = 12'o2210;
      FCVT_D_S:  reg_state = 12'o2210;
      FSGNJ_D:   reg_state = 12'o2220;
      FSGNJN_D:  reg_state = 12'o2220;
      FSGNJX_D:  reg_state = 12'o2220;
      FMV_X_D:   reg_state = 12'o1200;
      FMV_D_X:   reg_state = 12'o2100;
      FEQ_D:     reg_state = 12'o1220;
      FLT_D:     reg_state = 12'o1220;
      FLE_D:     reg_state = 12'o1220;
      FCLASS_D:  reg_state = 12'o1200;
      INVALID:   reg_state = 12'o0000;
    endcase
  end

  // determine type of immediate per instruction
  always_comb begin : immediate_mapping
    unique case (exp_cmd_o.func)
      LUI:       imm_src_infer = UIMM;
      AUIPC:     imm_src_infer = UIMM;
      JAL:       imm_src_infer = JIMM;
      JALR:      imm_src_infer = IIMM;
      BEQ:       imm_src_infer = BIMM;
      BNE:       imm_src_infer = BIMM;
      BLT:       imm_src_infer = BIMM;
      BGE:       imm_src_infer = BIMM;
      BLTU:      imm_src_infer = BIMM;
      BGEU:      imm_src_infer = BIMM;
      LB:        imm_src_infer = IIMM;
      LH:        imm_src_infer = IIMM;
      LW:        imm_src_infer = IIMM;
      LBU:       imm_src_infer = IIMM;
      LHU:       imm_src_infer = IIMM;
      SB:        imm_src_infer = SIMM; //
      SH:        imm_src_infer = SIMM; //
      SW:        imm_src_infer = SIMM; //
      ADDI:      imm_src_infer = IIMM;
      SLTI:      imm_src_infer = IIMM;
      SLTIU:     imm_src_infer = IIMM;
      XORI:      imm_src_infer = IIMM;
      ORI:       imm_src_infer = IIMM;
      ANDI:      imm_src_infer = IIMM;
      SLLI:      imm_src_infer = AIMM;
      SRLI:      imm_src_infer = AIMM;
      SRAI:      imm_src_infer = AIMM;
      ADD:       imm_src_infer = RIMM;
      SUB:       imm_src_infer = RIMM;
      SLL:       imm_src_infer = RIMM;
      SLT:       imm_src_infer = RIMM;
      SLTU:      imm_src_infer = RIMM;
      XOR:       imm_src_infer = RIMM;
      SRL:       imm_src_infer = RIMM;
      SRA:       imm_src_infer = RIMM;
      OR:        imm_src_infer = RIMM;
      AND:       imm_src_infer = RIMM;
      FENCE:     imm_src_infer = IIMM; // requires attention
      FENCE_TSO: imm_src_infer = NONE;
      PAUSE:     imm_src_infer = NONE;
      ECALL:     imm_src_infer = NONE;
      EBREAK:    imm_src_infer = NONE;
      LWU:       imm_src_infer = IIMM;
      LD:        imm_src_infer = IIMM;
      SD:        imm_src_infer = SIMM; //
      ADDIW:     imm_src_infer = IIMM;
      SLLIW:     imm_src_infer = AIMM;
      SRLIW:     imm_src_infer = AIMM;
      SRAIW:     imm_src_infer = AIMM;
      ADDW:      imm_src_infer = RIMM;
      SUBW:      imm_src_infer = RIMM;
      SLLW:      imm_src_infer = RIMM;
      SRLW:      imm_src_infer = RIMM;
      SRAW:      imm_src_infer = RIMM;
      CSRRW:     imm_src_infer = CIMM;
      CSRRS:     imm_src_infer = CIMM;
      CSRRC:     imm_src_infer = CIMM;
      CSRRWI:    imm_src_infer = CIMM; // requires attention
      CSRRSI:    imm_src_infer = CIMM; // requires attention
      CSRRCI:    imm_src_infer = CIMM; // requires attention
      MUL:       imm_src_infer = RIMM;
      MULH:      imm_src_infer = RIMM;
      MULHSU:    imm_src_infer = RIMM;
      MULHU:     imm_src_infer = RIMM;
      DIV:       imm_src_infer = RIMM;
      DIVU:      imm_src_infer = RIMM;
      REM:       imm_src_infer = RIMM;
      REMU:      imm_src_infer = RIMM;
      MULW:      imm_src_infer = RIMM;
      DIVW:      imm_src_infer = RIMM;
      DIVUW:     imm_src_infer = RIMM;
      REMW:      imm_src_infer = RIMM;
      REMUW:     imm_src_infer = RIMM;
      LR_W:      imm_src_infer = TIMM;
      SC_W:      imm_src_infer = TIMM;
      AMOSWAP_W: imm_src_infer = TIMM;
      AMOADD_W:  imm_src_infer = TIMM;
      AMOXOR_W:  imm_src_infer = TIMM;
      AMOAND_W:  imm_src_infer = TIMM;
      AMOOR_W:   imm_src_infer = TIMM;
      AMOMIN_W:  imm_src_infer = TIMM;
      AMOMAX_W:  imm_src_infer = TIMM;
      AMOMINU_W: imm_src_infer = TIMM;
      AMOMAXU_W: imm_src_infer = TIMM;
      LR_D:      imm_src_infer = TIMM;
      SC_D:      imm_src_infer = TIMM;
      AMOSWAP_D: imm_src_infer = TIMM;
      AMOADD_D:  imm_src_infer = TIMM;
      AMOXOR_D:  imm_src_infer = TIMM;
      AMOAND_D:  imm_src_infer = TIMM;
      AMOOR_D:   imm_src_infer = TIMM;
      AMOMIN_D:  imm_src_infer = TIMM;
      AMOMAX_D:  imm_src_infer = TIMM;
      AMOMINU_D: imm_src_infer = TIMM;
      AMOMAXU_D: imm_src_infer = TIMM;
      FLW:       imm_src_infer = IIMM;
      FSW:       imm_src_infer = SIMM; //
      FADD_S:    imm_src_infer = RIMM;
      FSUB_S:    imm_src_infer = RIMM;
      FMUL_S:    imm_src_infer = RIMM;
      FDIV_S:    imm_src_infer = RIMM;
      FSQRT_S:   imm_src_infer = RIMM;
      FMIN_S:    imm_src_infer = RIMM;
      FMAX_S:    imm_src_infer = RIMM;
      FMADD_S:   imm_src_infer = RIMM;
      FMSUB_S:   imm_src_infer = RIMM;
      FNMADD_S:  imm_src_infer = RIMM;
      FNMSUB_S:  imm_src_infer = RIMM;
      FCVT_W_S:  imm_src_infer = RIMM;
      FCVT_WU_S: imm_src_infer = RIMM;
      FCVT_L_S:  imm_src_infer = RIMM;
      FCVT_LU_S: imm_src_infer = RIMM;
      FCVT_S_W:  imm_src_infer = RIMM;
      FCVT_S_WU: imm_src_infer = RIMM;
      FCVT_S_L:  imm_src_infer = RIMM;
      FCVT_S_LU: imm_src_infer = RIMM;
      FSGNJ_S:   imm_src_infer = RIMM;
      FSGNJN_S:  imm_src_infer = RIMM;
      FSGNJX_S:  imm_src_infer = RIMM;
      FMV_X_W:   imm_src_infer = RIMM;
      FMV_W_X:   imm_src_infer = RIMM;
      FEQ_S:     imm_src_infer = RIMM;
      FLT_S:     imm_src_infer = RIMM;
      FLE_S:     imm_src_infer = RIMM;
      FCLASS_S:  imm_src_infer = RIMM;
      FLD:       imm_src_infer = IIMM;
      FSD:       imm_src_infer = SIMM; //
      FADD_D:    imm_src_infer = RIMM;
      FSUB_D:    imm_src_infer = RIMM;
      FMUL_D:    imm_src_infer = RIMM;
      FDIV_D:    imm_src_infer = RIMM;
      FSQRT_D:   imm_src_infer = RIMM;
      FMIN_D:    imm_src_infer = RIMM;
      FMAX_D:    imm_src_infer = RIMM;
      FMADD_D:   imm_src_infer = RIMM;
      FMSUB_D:   imm_src_infer = RIMM;
      FNMADD_D:  imm_src_infer = RIMM;
      FNMSUB_D:  imm_src_infer = RIMM;
      FCVT_W_D:  imm_src_infer = RIMM;
      FCVT_WU_D: imm_src_infer = RIMM;
      FCVT_L_D:  imm_src_infer = RIMM;
      FCVT_LU_D: imm_src_infer = RIMM;
      FCVT_D_W:  imm_src_infer = RIMM;
      FCVT_D_WU: imm_src_infer = RIMM;
      FCVT_D_L:  imm_src_infer = RIMM;
      FCVT_D_LU: imm_src_infer = RIMM;
      FCVT_S_D:  imm_src_infer = RIMM;
      FCVT_D_S:  imm_src_infer = RIMM;
      FSGNJ_D:   imm_src_infer = RIMM;
      FSGNJN_D:  imm_src_infer = RIMM;
      FSGNJX_D:  imm_src_infer = RIMM;
      FMV_X_D:   imm_src_infer = RIMM;
      FMV_D_X:   imm_src_infer = RIMM;
      FEQ_D:     imm_src_infer = RIMM;
      FLT_D:     imm_src_infer = RIMM;
      FLE_D:     imm_src_infer = RIMM;
      FCLASS_D:  imm_src_infer = RIMM;
      INVALID:   imm_src_infer = NONE; // Revision Done: 0;
    endcase                            // edit: 1;
  end

  // set source register 3 state and location
  always_comb begin : rs3
    unique case (reg_state[2:0])
      0: exp_cmd_o.rs3 = '0;
      1: exp_cmd_o.rs3 = {1'b0, code_i[31:27]};
      2: exp_cmd_o.rs3 = {1'b1, code_i[31:27]};
    endcase
  end

  // set source register 2 state and location
  always_comb begin : rs2
    unique case (reg_state[5:3])
      0: exp_cmd_o.rs2 = '0;
      1: exp_cmd_o.rs2 = {1'b0, code_i[24:20]};
      2: exp_cmd_o.rs2 = {1'b1, code_i[24:20]};
    endcase
  end

  // set source register 1 state and location
  always_comb begin : rs1
    unique case (reg_state[8:6])
      0: exp_cmd_o.rs1 = '0;
      1: exp_cmd_o.rs1 = {1'b0, code_i[19:15]};
      2: exp_cmd_o.rs1 = {1'b1, code_i[19:15]};
    endcase
  end

  // set destination register state and location
  always_comb begin : rd
    unique case (reg_state[11:9])
      0: exp_cmd_o.rd = '0;
      1: exp_cmd_o.rd = {1'b0, code_i[11:7]};
      2: exp_cmd_o.rd = {1'b1, code_i[11:7]};
    endcase
  end

  // set register requirement
  always_comb begin : reg_req
    if (exp_cmd_o.jump) exp_cmd_o.reg_req = '1;
    else begin
      exp_cmd_o.reg_req = '0;
      exp_cmd_o.reg_req[exp_cmd_o.rd] = 1'b1;
      exp_cmd_o.reg_req[exp_cmd_o.rs1] = 1'b1;
      exp_cmd_o.reg_req[exp_cmd_o.rs2] = 1'b1;
      exp_cmd_o.reg_req[exp_cmd_o.rs3] = 1'b1;
    end
  end

  // set immediate based on instruction type
  always_comb begin : imm
    unique case (imm_src_infer)
      NONE: exp_cmd_o.imm = '0;
      AIMM: begin // sign extended shift amount
        foreach(stand_imm[i]) stand_imm[i] = (code_i[25]);
        stand_imm[5:0] = code_i[25:20];
        exp_cmd_o.imm = stand_imm;
      end
      BIMM:begin // B-TYPE instructions
        foreach(stand_imm[i]) stand_imm[i] = (code_i[31]);
        stand_imm[12:0] = {code_i[31], code_i[7], code_i[30:25], code_i[11:8], 'b0};
        exp_cmd_o.imm = stand_imm;
      end
      CIMM:begin // csr instructions
        stand_imm[11:0] = code_i[31:20];
        stand_imm[16:12] = code_i[19:15];
        exp_cmd_o.imm = stand_imm;
      end
      IIMM:begin // I-TYPE instructions
        foreach(stand_imm[i]) stand_imm[i] = (code_i[31]);
        stand_imm[11:0] = code_i[31:20];
        exp_cmd_o.imm = stand_imm;
      end
      JIMM:begin // J-TYPE instructions
        foreach(stand_imm[i]) stand_imm[i] = (code_i[31]);
        stand_imm[20:0] = {code_i[31], code_i[19:12], code_i[20], code_i[30:21], 'b0};
        exp_cmd_o.imm = stand_imm;
      end
      RIMM: begin  // R-TYPE instructions
        stand_imm[2:0] = code_i[14:12];
        exp_cmd_o.imm = stand_imm;
      end
      SIMM: begin // S-TYPE instructions
        foreach(stand_imm[i]) stand_imm[i] = (code_i[31]);
        stand_imm[11:0] = {code_i[31:25], code_i[11:7]};
        exp_cmd_o.imm = stand_imm;
      end
      TIMM: begin
        stand_imm[1:0] = {code_i[26], code_i[25]};
        exp_cmd_o.imm = stand_imm;
      end
      UIMM: begin // U-TYPE instructions
        foreach(stand_imm[i]) stand_imm[i] = (code_i[31]);
        stand_imm[31:0] = {code_i[31:12], '0};
        exp_cmd_o.imm = stand_imm;
      end
      default: exp_cmd_o.imm = '0;
    endcase
  end
  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  rv64g_instr_decoder u_dut (
      .pc_i,
      .code_i,
      .cmd_o
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Task to start input-output monitoring
  task automatic start_in_out_mon();
    in_out_ok  = 1;
    tx_success = 0;
    instr_check = '0;
    fork
      forever begin
        @(posedge clk_i);
        foreach (output_vector_o[i]) begin // where is the output vector?? - Tahmeed
          if (exp_cmd_o !== cmd_o) begin
            in_out_ok = 0;
          end else begin
            tx_success += in_out_ok;
            instr_check[cmd_o.func] = 1'b1;
            count = instr_check.sum();
            if (count == NumInstr) ->e_all_instr_checked;
          end
        end
      end
    join_none
  endtask

  // Task to start random drive on inputs
  task automatic start_random_drive();
    stand_imm = '0;
    fork
      forever begin
        @(posedge clk_i);
        pc_i   <= $urandom;
        code_i <= $urandom;
      end
    join_none
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk_i) begin
    if (count == NumInstr) begin
      result_print(in_out_ok, $sformatf(
        "Data integrity. %0d transfers. All instruction types checked", tx_success));
      if (!in_out_ok) $display("Failed at expected func = %s, RTL func = %s",
       exp_cmd_o.func.name(), cmd_o.func.name());
      $finish;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Initial block to handle fatal timeout
  initial begin
    #5ms;
    $display("Success %d", tx_success);
    result_print(0, "FATAL TIMEOUT");
    $finish;
  end

  // Initial block to start clock, monitor & drive
  initial begin
    start_clk_i();
    start_in_out_mon();
    start_random_drive();
  end

endmodule
