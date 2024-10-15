`include "forwarding_unit_if.vh"
`include "cpu_types_pkg.vh"

module forwarding_unit (
    forwarding_unit_if fwif
);
    // Forwarding Logic
    always_comb begin
        // Default no forwarding
        fwif.forwardA = 2'b00;
        fwif.forwardB = 2'b00;

        // Forwarding for ALU input A (rs1)
        if (fwif.ex_mem_regwrite && (fwif.ex_mem_rd != 0) && (fwif.ex_mem_rd == fwif.rs1)) begin
            fwif.forwardA = 2'b10; // Forward from EX/MEM stage
        end else if (fwif.mem_wb_regwrite && (fwif.mem_wb_rd != 0) && (fwif.mem_wb_rd == fwif.rs1)) begin
            fwif.forwardA = 2'b01; // Forward from MEM/WB stage
        end

        // Forwarding for ALU input B (rs2)
        if (fwif.ex_mem_regwrite && (fwif.ex_mem_rd != 0) && (fwif.ex_mem_rd == fwif.rs2)) begin
            fwif.forwardB = 2'b10; // Forward from EX/MEM stage
        end else if (fwif.mem_wb_regwrite && (fwif.mem_wb_rd != 0) && (fwif.mem_wb_rd == fwif.rs2)) begin
            fwif.forwardB = 2'b01; // Forward from MEM/WB stage
        end
    end
endmodule
