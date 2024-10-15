



`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"


module control_unit (
control_unit_if cuif
);
// Import RISC-V package types
import cpu_types_pkg::*;


always_comb begin
  // Default control signal values
  cuif.ALUOP     = ALU_ADD;
  cuif.ALUSrc_t    = 1'b0;
  cuif.MemWrite  = 1'b0;
  cuif.MemToReg  = 1'b0;
  cuif.RegWen  = 1'b0;
  cuif.PcToReg   = 1'b0;
  cuif.jump_t    = 3'b000; // No jump
  cuif.halt      = 1'b0;
  cuif.RegDst_t  = 1'b0;   // Default to writing to rd
  cuif.branch_t  = 1'b0;


  // Decode the opcode field from the instruction
  case (cuif.Instr[6:0])  // 7-bit opcode field
    RTYPE: begin
      // R-Type instructions (e.g., ADD, SUB, AND, OR)
      cuif.RegWen = 1'b1;  // Write to register
      cuif.ALUSrc_t  = 1'b0;  // ALU source is from register
      cuif.RegDst_t   = 1'b1;  // Write to rd

      casez ({cuif.Instr[31:25], cuif.Instr[14:12]})  // funct7 and funct3
        {ADD, ADD_SUB}: cuif.ALUOP = ALU_ADD;  // ADD
        {SUB, ADD_SUB}: cuif.ALUOP = ALU_SUB;  // SUB
        {ADD, AND}:     cuif.ALUOP = ALU_AND;  // AND
        {ADD, OR}:      cuif.ALUOP = ALU_OR;   // OR
        {ADD, XOR}:     cuif.ALUOP = ALU_XOR;  // XOR
        {ADD, SLL}:     cuif.ALUOP = ALU_SLL;  // SLL
        {ADD, SRL_SRA}: cuif.ALUOP = ALU_SRL;  // SRL
        {SUB, SRL_SRA}: cuif.ALUOP = ALU_SRA;  // SRA
        {ADD, SLT}:     cuif.ALUOP = ALU_SLT;  // SLT
        {ADD, SLTU}:    cuif.ALUOP = ALU_SLTU; // SLTU
      endcase
    end

    ITYPE: begin
      // I-Type instructions (e.g., ADDI, ORI, ANDI)
      cuif.RegWen = 1'b1;  // Write to register
      cuif.ALUSrc_t  = 1'b1;  // ALU source is immediate
      cuif.RegDst_t   = 1'b1;  // Write to rd

      case (cuif.Instr[14:12])  // funct3 field
        ADDI: cuif.ALUOP = ALU_ADD;  // ADDI
        XORI: cuif.ALUOP = ALU_XOR;  // XORI
        ORI: cuif.ALUOP = ALU_OR;   // ORI
        ANDI: cuif.ALUOP = ALU_AND;  // ANDI
        SLLI: cuif.ALUOP = ALU_SLL;  // SLLI
        SRLI_SRAI: begin // SRLI/SRAI
          if (cuif.Instr[31:25] == 7'b0000000)
            cuif.ALUOP = ALU_SRL;  // SRLI
          else
            cuif.ALUOP = ALU_SRA;  // SRAI
        end
        SLTI: cuif.ALUOP = ALU_SLT;  // SLTI
        SLTIU: cuif.ALUOP = ALU_SLTU; // SLTIU
      endcase
    end

    ITYPE_LW: begin
      // Load instructions (e.g., LW)
      cuif.RegWen = 1'b1;  // Write to register
      cuif.ALUSrc_t  = 1'b1;  // ALU source is immediate
      cuif.ALUOP    = ALU_ADD; // ALU computes address
      cuif.MemToReg = 1'b1;  // Write data from memory to register
      cuif.RegDst_t   = 1'b1;
    end

    STYPE: begin
      // Store instructions (e.g., SW)
      cuif.MemWrite = 1'b1;  // Write to memory
      cuif.ALUSrc_t  = 1'b1;  // ALU source is immediate
      cuif.ALUOP    = ALU_ADD; // ALU computes address
    end

    BTYPE: begin
      // Branch instructions (e.g., BEQ, BNE)
      cuif.ALUSrc_t= 1'b0;    // ALU source is register
      case(cuif.Instr[14:12])  // funct3 field
        BEQ: begin
          cuif.branch_t = 0;
          cuif.ALUOP  = ALU_SUB;  // BEQ (compare registers)
          cuif.jump_t = 3'b001;   // Branch if equal
        end
        BNE: begin
          cuif.branch_t = 1;
          cuif.ALUOP  = ALU_SUB;  // BNE (compare registers)
          cuif.jump_t = 3'b001;   // Branch if not equal
        end
        BGE: begin
          cuif.branch_t = 0;
          cuif.ALUOP  = ALU_SLT;  // BGE (signed)
          cuif.jump_t = 3'b001;   // Branch if greater or equal
        end
        BGEU: begin
          cuif.branch_t = 0;
          cuif.ALUOP  = ALU_SLTU; // BGEU (unsigned)
          cuif.jump_t = 3'b001;   // Branch if greater or equal (unsigned)
        end
        BLT: begin
          cuif.branch_t = 1;
          cuif.ALUOP  = ALU_SLT;  // BLT (signed)
          cuif.jump_t = 3'b001;   // Branch if less than
        end
        BLTU: begin
          cuif.branch_t = 1;
          cuif.ALUOP  = ALU_SLTU; // BLTU (unsigned)
          cuif.jump_t = 3'b001;   // Branch if less than (unsigned)
        end
      endcase
    end


    JAL: begin
      // Jump and Link (JAL)
      cuif.jump_t  = 3'b010;   // Jump
      cuif.RegWen = 1'b1;    // Write to rd
      cuif.PcToReg  = 1'b1;    // Store PC+4 to rd
      cuif.RegDst_t   = 1'b1;
    end

    JALR: begin
      // Jump and Link Register (JALR)
      cuif.jump_t  = 3'b011;   // JALR
      cuif.ALUSrc_t = 1'b1;     // ALU source is immediate
      cuif.ALUOP   = ALU_ADD;  // ALU adds offset to rs1
      cuif.RegWen = 1'b1;    // Write to rd
      cuif.PcToReg  = 1'b1;    // Store PC+4 to rd
      cuif.RegDst_t   = 1'b1;
    end

    LUI: begin
      // Load Upper Immediate (LUI)
      cuif.RegWen = 1'b1;   // Write to rd
      cuif.ALUSrc_t  = 1'b1;   // Use immediate
      cuif.ALUOP    = ALU_ADD; // ALU computes the immediate
      cuif.MemToReg = 1'b0;   // No memory load
      cuif.RegDst_t   = 1'b1;
    end
    
    AUIPC: begin 
      cuif.RegWen = 1'b1;   // Write to rd
      cuif.ALUSrc_t  = 1'b1;   // Use immediate
      cuif.ALUOP    = ALU_ADD; // ALU computes the immediate
      cuif.MemToReg = 1'b0;   // No memory load
      cuif.PcToReg = 1;
      cuif.RegDst_t   = 1'b1;
    end


    HALT: begin
      // Halt instruction
      cuif.halt = 1'b1;
    end

    default: begin
    end
  endcase
end
endmodule

