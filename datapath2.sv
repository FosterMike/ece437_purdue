/*
 Eric Villasenor
 evillase@gmail.com

 datapath contains register file, control, hazard,
 muxes, and glue logic for processor
*/

// data path interface

`include "datapath_cache_if.vh"
`include "control_unit_if.vh"
`include "memory_request_if.vh"
`include "register_file_if.vh"
`include "ALU_if.vh"


module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // Import necessary packages and types
  import cpu_types_pkg::*;


  // PC initialization value
  parameter PC_INIT = 0;


  // Program counter and next PC
  word_t pc;
  word_t n_pc;
  logic pcEN;


  // Immediate values for various RISC-V instruction types
  word_t seImm;   // Signed immediate for I/S/B-types
  word_t luiImm;  // Immediate for LUI instruction
  word_t jalImm;  // Immediate for JAL instruction
  word_t bImm;
  word_t Imm;
  word_t stImm;

  // Interfaces for the control unit, memory request, register file, and ALU
  control_unit_if cuif();
  memory_request_if ruif();
  register_file_if rfif();
  alu_if aluif();

  // Instantiate the control unit, memory request unit, register file, and ALU
  control_unit CU (cuif);
  memory_request MR (CLK, nRST, ruif);
  register_file RF (CLK, nRST, rfif);
  ALU arithmetic (aluif);

   // Control Unit Interface setup
  assign cuif.Instr = dpif.imemload;

  // Immediate value calculations for RISC-V
  always_comb begin
      // I-type: Sign-extend 12-bit immediate
      seImm = {{20{dpif.imemload[31]}}, dpif.imemload[31:20]}; 
      // LUI-type: Upper immediate (20 bits shifted left by 12)
      luiImm = {dpif.imemload[31:12], 12'b0};
      // J-type (JAL): 20-bit immediate (sign-extended)
      jalImm = {{12{dpif.imemload[31]}}, dpif.imemload[19:12], dpif.imemload[20], dpif.imemload[30:21], 1'b0};
      // B-type: 
      bImm = {{20{dpif.imemload[31]}}, dpif.imemload[7], dpif.imemload[30:25], dpif.imemload[11:8], 1'b0};
      // Store type
      stImm = {{20{dpif.imemload[31]}}, dpif.imemload[31:25], dpif.imemload[11:7]};
  end

  // Memory Request Interface setup
  assign ruif.MemToReg = cuif.MemToReg;
  assign ruif.MemWrite = cuif.MemWrite;
  assign ruif.dhit = dpif.dhit;
  assign ruif.ihit = dpif.ihit;
   
   
   logic halt, next_halt;
   always_comb begin
       next_halt = halt | cuif.halt;
   end

   always_ff @(posedge CLK, negedge nRST) begin
       if(!nRST) begin
           halt <= 0;
       end
       else begin
           halt <= next_halt;
       end
   end
  
  // Register File Interface setup
  always_comb begin
      rfif.WEN = cuif.RegWen && (dpif.ihit || dpif.dhit);
      rfif.wsel = (cuif.RegDst_t == 1) ? dpif.imemload[11:7] : 5'b0;  // Rd in R/I-type
      rfif.rsel1 = dpif.imemload[19:15];  // Rs1
      rfif.rsel2 = dpif.imemload[24:20];  // Rs2 (for R-type or S/B-type)

      // Write data based on MemToReg control
      if (cuif.MemToReg) begin
              rfif.wdat = dpif.dmemload;  // Load result from memory
      end else if (cuif.PcToReg) begin
          if (cuif.jump_t == 3'b010) begin
              rfif.wdat = pc + 4;  // Store PC+4 for JAL/JALR
          end
          else begin
              rfif.wdat = pc + luiImm; // stor PC + lui for AUIPC
          end
      end else begin
          rfif.wdat = opcode_t'(dpif.imemload[6:0]) == LUI ? luiImm : aluif.out;  // ALU result
      end
  end

  // ALU Interface setup
  always_comb begin
      aluif.op = cuif.ALUOP;
      aluif.a = rfif.rdat1;

      Imm = 0;
      
      case (dpif.imemload[6:0])
          ITYPE: Imm = seImm;
          ITYPE_LW: Imm = seImm;
          STYPE: Imm = stImm;
          BTYPE: Imm = bImm;
      endcase
      // ALUSrc: choose between register data, immediate, or shift amount
      case (cuif.ALUSrc_t)
          1'b0: aluif.b = rfif.rdat2;  // Rs2 (R-type)
          1'b1: aluif.b = Imm;       // Immediate (I-type, S-type, B-type)
          default: aluif.b = 32'b0;
      endcase
  end

  // Program Counter (PC) logic
  always_ff @(posedge CLK, negedge nRST) begin
      if (!nRST) begin
          // Reset PC
          pc <= PC_INIT;
      end else if (pcEN) begin
          // Update PC if enabled
          pc <= n_pc;
      end
  end

  // Next PC selection logic for RISC-V jumps and branches
  always_comb begin
      n_pc = pc + 4;  // Default next PC is PC + 4
      case (cuif.jump_t)
          3'b000: n_pc = pc + 4;                    // No jump
          3'b001: begin
               n_pc = cuif.branch_t ? ((aluif.out != 0) ? (pc + $signed(bImm)) : (pc + 4)) : ((aluif.out == 0) ? (pc + $signed(bImm)) : (pc + 4));
          end
          3'b010: n_pc = $signed(jalImm) + pc;               // JAL
          3'b011: n_pc = rfif.rdat1 + $signed(seImm);        // JALR
          
          default: n_pc = pc + 4;                   // Default to PC + 4
      endcase
  end

  // PC Enable: based on insrtuction hit status (instruction memory hit, no data cache miss)
  assign pcEN = dpif.ihit;

  // Datapath Outputs
  assign dpif.halt = halt;
  assign dpif.imemREN = 1'b1;  // Always read instructions
  assign dpif.imemaddr = pc;
  assign dpif.dmemREN = ruif.dmemREN;
  assign dpif.dmemWEN = ruif.dmemWEN;
  assign dpif.dmemstore = rfif.rdat2;
  assign dpif.dmemaddr = aluif.out;
endmodule


