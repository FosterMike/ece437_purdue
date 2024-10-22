
`ifndef FORWARDING_UNIT_IF_VH
`define FORWARDING_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface forwarding_unit_if;
    logic [4:0] rs1;       // Source register 1 (ID/EX stage)
    logic [4:0] rs2;       // Source register 2 (ID/EX stage)
    logic [4:0] ex_mem_rd; // Destination register in EX/MEM stage
    logic [4:0] mem_wb_rd; // Destination register in MEM/WB stage
    logic ex_mem_regwrite; // RegWrite signal from EX/MEM stage
    logic mem_wb_regwrite; // RegWrite signal from MEM/WB stage
    logic mem_wb_memtoreg;
    logic ex_mem_memtoreg;
    logic [31:0] ex_mem_aluout; // ALU result from EX/MEM stage
    logic [31:0] mem_wb_wdata;  // Writeback data from MEM/WB stage
    logic [31:0] storedA;
    logic [31:0] storedB;
    logic [1:0] forwardA; // Forwarding control for ALU input A
    logic [1:0] forwardB; // Forwarding control for ALU input B
endinterface
`endif
