
`include "hazard_unit_if.vh"
`include "cpu_types_pkg.vh"
module hazard_unit (
    hazard_unit_if hzif
);
    // Load-use hazard detection
    always_comb begin
        hzif.stall = 0;
        hzif.pc_write = 1;
        hzif.if_id_write = 1;
        hzif.hazard_detected = 0;

        // Check for load-use hazard
        if (hzif.ex_mem_memread && (hzif.ex_mem_rd != 0) && 
          ((hzif.ex_mem_rd == hzif.rs1) || (hzif.ex_mem_rd == hzif.rs2))) begin
            // If hazard detected, stall pipeline by stopping PC and IF/ID register update
            hzif.stall = 1;
            hzif.pc_write = 0;
            hzif.if_id_write = 0;
            hzif.hazard_detected = 1;
        end
        if(!hzif.dhit && (hzif.ex_mem_memread || hzif.ex_mem_memwrite)) begin
            hzif.stall = 1;
            hzif.pc_write = 0;
            hzif.if_id_write = 0;
        end
    end
endmodule
