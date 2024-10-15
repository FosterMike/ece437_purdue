`ifndef CONTR_UNIT_IF_VH
`define CONTR_UNIT_IF_VH

// Import necessary package
`include "cpu_types_pkg.vh"

// Control unit interface
interface control_unit_if;
  import cpu_types_pkg::*;

  logic [31:0] Instr;       // Full instruction to be decoded

  logic [2:0] jump_t;       // Determines the type of jump (000 = no jump, etc.)
  logic [1:0] RegDst_t;     // Selects destination register (00 = Rd, 01 = Rt, 10 = 31 for JAL)
  logic       RegWen;       // Register write enable
  logic [2:0] ALUSrc_t;     // ALU input source selection (000 = register, 001 = signed immediate, etc.)
  aluop_t     ALUOP;        // ALU operation code (from aluop_t enum)
  logic       MemToReg;     // Selects between ALU result and memory data for register write-back
  logic       PcToReg;      // Write PC + 4 to register (for JAL)
  logic       MemWrite;     // Memory write enable
  logic       checkOF;      // Overflow check enable (only in specific ALU operations)
  logic       branch_t;      // ALU exp out for conditional branch
  logic       halt;         // Halt signal to stop execution

endinterface

`endif // CONTR_UNIT_IF_VH
