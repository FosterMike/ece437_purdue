
`ifndef DATAPATH_PIPELINE_IF_VH
`define DATAPATH_PIPELINE_IF_VH

`include "cpu_types_pkg.vh"
interface datapath_pipeline_if;

    // IF/ID Pipeline Registers
    logic [31:0] if_id_pc;          // PC at IF stage
    logic [31:0] if_id_instr;       // Instruction at IF stage

    // ID/EX Pipeline Registers
    logic [31:0] id_ex_pc;          // PC at ID stage
    logic [31:0] id_ex_instr;       // Instruction at ID stage
    logic [31:0] id_ex_rdata1;      // Register data 1 (rs1)
    logic [31:0] id_ex_rdata2;      // Register data 2 (rs2)
    logic [31:0] id_ex_imm;         // Immediate value
    logic [4:0]  id_ex_rd;          // Destination register (rd)
    logic [3:0]  id_ex_aluop;       // ALU operation
    logic        id_ex_alusrc;      // ALU source select (immediate or register)
    logic        id_ex_memtoreg;    // Memory to register control
    logic        id_ex_memwrite;    // Memory write control
    logic        id_ex_regwrite;    // Register write enable
    logic        id_ex_pctoreg;     // PC to register control (JAL/JALR)
    logic [2:0]  id_ex_jump_t;        // Jump type (JAL/JALR/branch)
    logic        id_ex_checkOF;     // Check for ALU overflow
    logic        id_ex_branch_t;    // Branch condition
    logic        id_ex_halt;        // Halt signal

    // EX/MEM Pipeline Registers
    logic [2:0]  ex_mem_jump_t;
    logic [31:0] ex_mem_pc;         // PC at EX stage
    logic [31:0] ex_mem_instr;      // Instruction at EX stage
    logic [31:0] ex_mem_aluout;     // ALU output
    logic [31:0] ex_mem_rdata2;     // Register data 2 (rs2) for memory writes
    logic [4:0]  ex_mem_rd;         // Destination register (rd)
    logic        ex_mem_memtoreg;   // Memory to register control
    logic        ex_mem_memwrite;   // Memory write enable
    logic        ex_mem_regwrite;   // Register write enable
    logic        ex_mem_pctoreg;    // PC to register control
    logic        ex_mem_halt;       // Halt signal
    logic [31:0] ex_mem_imm;        // Immediate for JAL/AUIPC
    logic        ex_mem_branch_t;

    // MEM/WB Pipeline Registers
    logic [2:0]  mem_wb_jump_t;
    logic [31:0] mem_wb_pc;         // PC at MEM stage
    logic [31:0] mem_wb_instr;      // Instruction at MEM stage
    logic [31:0] mem_wb_aluout;     // ALU output from EX stage
    logic [31:0] mem_wb_dmemload;   // Data loaded from memory (for load instructions)
    logic [4:0]  mem_wb_rd;         // Destination register (rd)
    logic        mem_wb_memtoreg;   // Memory to register control
    logic        mem_wb_regwrite;   // Register write enable
    logic        mem_wb_pctoreg;    // PC to register control (JAL/JALR)
    logic [31:0] mem_wb_imm;        // Immediate for JAL/AUIPC
    logic        mem_wb_halt;       // Halt signal for the WB stage
    logic [31:0] mem_wb_rdata2;

    // Hazard Control Signals
    logic        if_id_write;       // Control to write to IF/ID pipeline registers
    logic        stall;             // Stall signal to freeze pipeline stages
    logic        pc_write;          // Control to write to PC (disabled if pipeline is stalled)

    // Forwarding Control Signals
    logic [1:0]  forwardA;          // Forwarding control for ALU input A
    logic [1:0]  forwardB;          // Forwarding control for ALU input B

endinterface
`endif
