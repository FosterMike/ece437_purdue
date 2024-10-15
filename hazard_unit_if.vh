`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface hazard_unit_if;
    logic [4:0] rs1;     // Source register 1 (ID stage)
    logic [4:0] rs2;     // Source register 2 (ID stage)
    logic [4:0] ex_mem_rd;   // Destination register in EX/MEM stage
    logic ex_mem_regwrite;   // RegWrite signal from EX/MEM stage
    logic [4:0] mem_wb_rd;   // Destination register in MEM/WB stage
    logic mem_wb_regwrite;   // RegWrite signal from MEM/WB stage
    logic ex_mem_memread;    // MemRead signal from EX/MEM stage (for load-use hazards)
    logic ex_mem_memwrite;
    logic dhit;

    logic stall;       // Stall signal to pipeline
    logic pc_write;    // PC write enable
    logic if_id_write; // IF/ID register write enable
    logic hazard_detected; // High when a hazard is detected
endinterface
`endif
