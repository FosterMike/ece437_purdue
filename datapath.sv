`include "datapath_pipeline_if.vh"
`include "control_unit_if.vh"
`include "memory_request_if.vh"
`include "register_file_if.vh"
`include "ALU_if.vh"
`include "hazard_unit_if.vh"
`include "forwarding_unit_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

module datapath (
    input logic CLK, nRST,
    datapath_cache_if dpif // Main interface instance for the pipeline


);
    import cpu_types_pkg::*;

    parameter PC_INIT;

    // Internal pipeline interface instance
    datapath_pipeline_if plif(); // Instance of the pipeline interface

    // Hazard and Forwarding Interfaces
    hazard_unit_if hzif();
    forwarding_unit_if fwif();

    // Program Counter and Signals
    word_t pc;
    word_t n_pc;
    logic pcEN;

    // Immediate values for various RISC-V instruction types
    word_t seImm;   // Signed immediate for I/S/B-types
    word_t luiImm;  // Immediate for LUI instruction
    word_t jalImm;  // Immediate for JAL instruction
    word_t bImm;    // Immediate for B-type
    word_t Imm;     // General immediate
    word_t stImm;   // Immediate for store instructions
    word_t forwarded_rdata2;

    // Interfaces for control unit, memory request, register file, and ALU
    control_unit_if cuif();
    memory_request_if ruif();
    register_file_if rfif();
    alu_if aluif();

    // Instantiate the control unit, memory request, register file, and ALU
    control_unit CU (cuif);
    memory_request MR (CLK, nRST, ruif);
    register_file RF (CLK, nRST, rfif);
    ALU arithmetic (aluif);
    hazard_unit HU (hzif);
    forwarding_unit FU (fwif);

    logic branch_taken;
    logic jump_taken;

    // Hazard Detection Setup
    assign hzif.rs1 = plif.if_id_instr[19:15];
    assign hzif.rs2 = plif.if_id_instr[24:20];
    assign hzif.ex_mem_rd = plif.ex_mem_rd;
    assign hzif.ex_mem_regwrite = plif.ex_mem_regwrite;
    assign hzif.mem_wb_rd = plif.mem_wb_rd;
    assign hzif.mem_wb_regwrite = plif.mem_wb_regwrite;
    assign hzif.ex_mem_memread = plif.ex_mem_memtoreg;
    assign hzif.dhit = dpif.dhit;
    assign hzif.ex_mem_memwrite = plif.ex_mem_memwrite;

    // Forwarding Unit Setup
    assign fwif.rs1 = plif.id_ex_instr[19:15];
    assign fwif.rs2 = plif.id_ex_instr[24:20];
    assign fwif.ex_mem_rd = plif.ex_mem_rd;
    assign fwif.mem_wb_rd = plif.mem_wb_rd;
    assign fwif.ex_mem_regwrite = plif.ex_mem_regwrite;
    assign fwif.mem_wb_regwrite = plif.mem_wb_regwrite;
    assign fwif.ex_mem_aluout = plif.ex_mem_aluout;
    assign fwif.mem_wb_wdata = (plif.mem_wb_memtoreg) ? plif.mem_wb_dmemload : plif.mem_wb_aluout;

    // IF Stage: Instruction Fetch
    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            plif.if_id_pc <= '0;
            plif.if_id_instr <= '0;
        end 
        else if (branch_taken || jump_taken) begin
            plif.if_id_pc <= '0;
            plif.if_id_instr <= '0;
        end
        else if (hzif.if_id_write) begin
            if (dpif.ihit) begin
                plif.if_id_pc <= pc; // Update IF/ID PC
                plif.if_id_instr <= dpif.imemload; // Fetch instruction from memory
            end 
        end
    end

    assign cuif.Instr = plif.if_id_instr;

    // ID Stage: Instruction Decode
    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            plif.id_ex_pc <= '0;
            plif.id_ex_instr <= '0;
            plif.id_ex_rdata1 <= '0;
            plif.id_ex_rdata2 <= '0;
            plif.id_ex_imm <= '0;
            plif.id_ex_rd <= '0;
            plif.id_ex_aluop <= '0;
            plif.id_ex_alusrc <= 0;
            plif.id_ex_memtoreg <= 0;
            plif.id_ex_memwrite <= 0;
            plif.id_ex_regwrite <= 0;
            plif.id_ex_pctoreg <= 0;
            plif.id_ex_jump_t <= '0;
            plif.id_ex_memwrite <= '0;
            plif.id_ex_checkOF <= '0;
            plif.id_ex_branch_t <= '0;
            plif.id_ex_halt <= '0;
        end 
        else if (branch_taken || jump_taken) begin
            plif.id_ex_pc <= '0;
            plif.id_ex_instr <= '0;
            plif.id_ex_rdata1 <= '0;
            plif.id_ex_rdata2 <= '0;
            plif.id_ex_imm <= '0;
            plif.id_ex_rd <= '0;
            plif.id_ex_aluop <= '0;
            plif.id_ex_alusrc <= 0;
            plif.id_ex_memtoreg <= 0;
            plif.id_ex_memwrite <= 0;
            plif.id_ex_regwrite <= 0;
            plif.id_ex_pctoreg <= 0;
            plif.id_ex_jump_t <= '0;
            plif.id_ex_memwrite <= '0;
            plif.id_ex_checkOF <= '0;
            plif.id_ex_branch_t <= '0;
            plif.id_ex_halt <= '0;
        end
        else if (!hzif.stall && dpif.ihit) begin
            plif.id_ex_pc <= plif.if_id_pc;
            plif.id_ex_instr <= plif.if_id_instr;
            plif.id_ex_rdata1 <= rfif.rdat1; // Register data 1
            plif.id_ex_rdata2 <= rfif.rdat2; // Register data 2
            plif.id_ex_imm <= Imm; // Immediate value
            plif.id_ex_rd <= cuif.RegDst_t ? plif.if_id_instr[11:7] : 5'b0; // Destination register
            plif.id_ex_aluop <= cuif.ALUOP;
            plif.id_ex_alusrc <= cuif.ALUSrc_t;
            plif.id_ex_memtoreg <= cuif.MemToReg;
            plif.id_ex_memwrite <= cuif.MemWrite;
            plif.id_ex_regwrite <= cuif.RegWen;
            plif.id_ex_pctoreg <= cuif.PcToReg;
            plif.id_ex_jump_t <= cuif.jump_t;
            plif.id_ex_checkOF <= cuif.checkOF;
            plif.id_ex_branch_t <= cuif.branch_t;
            plif.id_ex_halt <= cuif.halt;
        end
        //else if (dpif.dhit || hzif.stall) begin
        //end 
    end

    always_comb begin
        case(fwif.forwardB) 
            2'b00: forwarded_rdata2 = plif.id_ex_rdata2;
            2'b10: forwarded_rdata2 = plif.ex_mem_aluout;
            2'b01: forwarded_rdata2 = fwif.mem_wb_wdata;
            default: forwarded_rdata2 = plif.id_ex_rdata2;
        endcase
    end
    
    // EX Stage: ALU Operation and Forwarding
    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            plif.ex_mem_jump_t <= '0;
            plif.ex_mem_instr <= '0;
            plif.ex_mem_pc <= '0;
            plif.ex_mem_aluout <= '0;
            plif.ex_mem_rdata2 <= '0;
            plif.ex_mem_rd <= '0;
            plif.ex_mem_memtoreg <= 0;
            plif.ex_mem_memwrite <= 0;
            plif.ex_mem_regwrite <= 0;
            plif.ex_mem_pctoreg <= '0;
            plif.ex_mem_halt <= '0;
            plif.ex_mem_imm <= '0;
            plif.ex_mem_branch_t <= '0;
        end 
        else if ((dpif.dhit || branch_taken || jump_taken)) begin
            plif.ex_mem_jump_t <= '0;
            plif.ex_mem_instr <= 0;
            plif.ex_mem_pc <= 0;
            plif.ex_mem_aluout <= '0;
            plif.ex_mem_rdata2 <= '0;
            plif.ex_mem_rd <= '0;
            plif.ex_mem_memtoreg <= 0;
            plif.ex_mem_memwrite <= 0;
            plif.ex_mem_regwrite <= 0;
            plif.ex_mem_pctoreg <= '0;
            plif.ex_mem_halt <= '0;
            plif.ex_mem_imm <= '0;
            plif.ex_mem_branch_t <= '0;
        end
        else if (!hzif.stall && dpif.ihit) begin
            plif.ex_mem_jump_t <= plif.id_ex_jump_t;
            plif.ex_mem_imm <= plif.id_ex_imm;
            plif.ex_mem_instr <= plif.id_ex_instr;
            plif.ex_mem_pc <= plif.id_ex_pc;
            plif.ex_mem_aluout <= aluif.out; // ALU result
            plif.ex_mem_rdata2 <= forwarded_rdata2; // Data for memory store
            plif.ex_mem_rd <= plif.id_ex_rd;
            plif.ex_mem_memtoreg <= plif.id_ex_memtoreg;
            plif.ex_mem_memwrite <= plif.id_ex_memwrite;
            plif.ex_mem_regwrite <= plif.id_ex_regwrite;
            plif.ex_mem_pctoreg <= plif.id_ex_pctoreg;
            plif.ex_mem_halt <= plif.id_ex_halt;
            plif.ex_mem_branch_t <= plif.id_ex_branch_t;
        end
        
    end

    always_comb begin
        // if (!hzif.stall) begin
            // Forwarding logic
            aluif.op = plif.id_ex_aluop;
            case (fwif.forwardA)
                2'b00: aluif.a = plif.id_ex_rdata1; // No forwarding
                2'b10: aluif.a = plif.ex_mem_aluout; // Forward from EX/MEM stage
                2'b01: aluif.a = fwif.mem_wb_wdata; // Forward from MEM/WB stage
                default: aluif.a = plif.id_ex_rdata1;
            endcase

            case (fwif.forwardB)
                2'b00: aluif.b = (plif.id_ex_alusrc) ? plif.id_ex_imm : plif.id_ex_rdata2; // No forwarding
                2'b10: aluif.b = (plif.id_ex_alusrc) ? plif.id_ex_imm : plif.ex_mem_aluout; // Forward from EX/MEM stage
                2'b01: aluif.b = (plif.id_ex_alusrc) ? plif.id_ex_imm : fwif.mem_wb_wdata; // Forward from MEM/WB stage
                default: aluif.b = (plif.id_ex_alusrc) ? plif.id_ex_imm : plif.id_ex_rdata2;
            endcase
    end
    // MEM Stage: Memory Access
    always_ff @(posedge CLK, negedge nRST) begin
        if (!nRST) begin
            plif.mem_wb_instr <= '0;
            plif.mem_wb_pc <= '0;
            plif.mem_wb_aluout <= '0;
            plif.mem_wb_dmemload <= '0;
            plif.mem_wb_rd <= '0;
            plif.mem_wb_memtoreg <= 0;
            plif.mem_wb_regwrite <= 0;
            plif.mem_wb_pctoreg <= '0;
            plif.mem_wb_imm <= '0;
            plif.mem_wb_jump_t <= '0;
            plif.mem_wb_rdata2 <= 0;
        end else begin
            if(dpif.ihit || dpif.dhit || branch_taken || jump_taken) begin
            plif.mem_wb_jump_t <= plif.ex_mem_jump_t;
            plif.mem_wb_imm <= plif.ex_mem_imm;
            plif.mem_wb_instr <= plif.ex_mem_instr;
            plif.mem_wb_pc <= plif.ex_mem_pc;
            plif.mem_wb_aluout <= plif.ex_mem_aluout;
            plif.mem_wb_dmemload <= dpif.dmemload; // Data from memory
            plif.mem_wb_rd <= plif.ex_mem_rd;
            plif.mem_wb_memtoreg <= plif.ex_mem_memtoreg;
            plif.mem_wb_regwrite <= plif.ex_mem_regwrite;
            plif.mem_wb_pctoreg <= plif.ex_mem_pctoreg;
            plif.mem_wb_rdata2 <= plif.ex_mem_rdata2;
            end
        end
    end

  // Register File Interface setup
  always_comb begin
      rfif.WEN = plif.mem_wb_regwrite;
      rfif.wsel = plif.mem_wb_rd;  // Rd in R/I-type
      rfif.rsel1 = plif.if_id_instr[19:15];  // Rs1
      rfif.rsel2 = plif.if_id_instr[24:20];  // Rs2 (for R-type or S/B-type)

      // Write data based on MemToReg control
      if (plif.mem_wb_memtoreg) begin
              rfif.wdat = plif.mem_wb_dmemload;  // Load result from memory
      end else if (plif.mem_wb_pctoreg) begin
          if (plif.mem_wb_jump_t == 3'b010) begin
              rfif.wdat = plif.mem_wb_pc + 4;  // Store PC+4 for JAL/JALR
          end
          else begin
              rfif.wdat = plif.mem_wb_pc + plif.mem_wb_imm; // stor PC + lui for AUIPC
          end
      end else begin
          rfif.wdat = (opcode_t'(plif.mem_wb_instr[6:0]) == LUI) ? plif.mem_wb_imm : plif.mem_wb_aluout;  
      end
  end

  // ALU Immediate Value Calculations
  always_comb begin


      Imm = 0;
      
      case (plif.if_id_instr[6:0])
          ITYPE: Imm = seImm;
          ITYPE_LW: Imm = seImm;
          STYPE: Imm = stImm;
          BTYPE: Imm = bImm;
          JAL: Imm = jalImm;
          AUIPC: Imm = luiImm;
          LUI: Imm = luiImm;
      endcase

  end
    // ALU and Immediate Value Calculations
    always_comb begin
        // Immediate calculations
        seImm = {{20{plif.if_id_instr[31]}}, plif.if_id_instr[31:20]}; // I-type sign-extend
        luiImm = {plif.if_id_instr[31:12], 12'b0}; // LUI-type
        jalImm = {{12{plif.if_id_instr[31]}}, plif.if_id_instr[19:12], plif.if_id_instr[20], plif.if_id_instr[30:21], 1'b0}; // J-type
        bImm = {{20{plif.if_id_instr[31]}}, plif.if_id_instr[7], plif.if_id_instr[30:25], plif.if_id_instr[11:8], 1'b0}; // B-type
        stImm = {{20{plif.if_id_instr[31]}}, plif.if_id_instr[31:25], plif.if_id_instr[11:7]}; // Store type
    end

  // Program Counter Update Logic
  always_ff @(posedge CLK, negedge nRST) begin
      if (!nRST) begin
          pc <= 0; // Reset PC
      end else if (pcEN) begin
          pc <= n_pc; // Update PC
      end
  end

  assign branch_taken = (plif.ex_mem_jump_t == 3'b001) && ((plif.ex_mem_aluout == 0) && !plif.ex_mem_branch_t || (!(plif.ex_mem_aluout == 0) && plif.ex_mem_branch_t));
  assign jump_taken = plif.ex_mem_jump_t == 3'b010 || plif.ex_mem_jump_t == 3'b011;

  // Next PC Selection Logic
  always_comb begin
      n_pc = pc + 4; // Default next PC
      case (plif.ex_mem_jump_t)
          3'b000: n_pc = pc + 4; // No jump
          3'b001: begin
            if (branch_taken) begin
                n_pc = plif.ex_mem_pc + $signed(plif.ex_mem_imm); // Branch target address

            end else begin
                n_pc = pc + 4; // Default to PC + 4 (branch not taken)
            end
          end
          3'b010: n_pc = plif.ex_mem_pc + $signed(plif.ex_mem_imm); // JAL
          3'b011: n_pc = plif.ex_mem_aluout; // JALR
          default: n_pc = pc + 4; // Default to PC + 4
      endcase
  end

  // PC Enable Logic
  assign pcEN = (dpif.ihit && hzif.pc_write) || branch_taken || jump_taken; // Enable PC if instruction cache hit and no hazard stall
    // logic halt_reg;
    // logic n_halt;
    always_ff @(posedge CLK, negedge nRST)
    begin
    if (!nRST) begin
        dpif.halt <= 0;
    end
    else begin
        dpif.halt <= dpif.halt || plif.ex_mem_halt;
    end
    end

    // assign n_halt = plif.ex_mem_halt;

  // Datapath Outputs to dpif
//   assign dpif.halt = halt_reg; // Halting signal
  assign dpif.imemREN = 1'b1;   // Always read instructions
  assign dpif.imemaddr = pc;    // Instruction memory address

  assign dpif.dmemREN = plif.ex_mem_memtoreg;
  assign dpif.dmemWEN = plif.ex_mem_memwrite;
  assign dpif.dmemstore = plif.ex_mem_rdata2; // Data to store
  assign dpif.dmemaddr = plif.ex_mem_aluout; // Address for memory operation

endmodule
