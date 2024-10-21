`include "memory_request_if.vh"
`include "cpu_types_pkg.vh"

module memory_request (
    input  logic CLK, nRST,                      // Clock and Reset
    memory_request_if mrif                       // Memory request interface
);

  import cpu_types_pkg::*;

  // Signals for memory enable (read and write)
  logic dmemREN_next;
  logic dmemWEN_next;

  // Next state logic for memory request signals
  always_comb begin
    // Initialize to no read or write
    dmemREN_next = mrif.dmemREN;
    dmemWEN_next = mrif.dmemWEN;

    if (mrif.dhit) begin
        dmemREN_next = 1'b0;
        dmemWEN_next = 1'b0;
    end
    
    if (mrif.ihit) begin
        dmemREN_next = mrif.MemToReg;
        dmemWEN_next = mrif.MemWrite;
    end
    // Memory load operations (read from memory) if dhit is false and memory load requested
    // if (mrif.dhit == 1'b0 && mrif.MemToReg == 1'b1) begin
    //   dmemREN_next = 1'b1;
    // end

    // // Memory store operations (write to memory) if dhit is false and memory write requested
    // else if (mrif.dhit == 1'b0 && mrif.MemWrite == 1'b1) begin
    //   dmemWEN_next = 1'b1;
    // end
  end

  // Sequential logic to store the results directly in interface signals
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) begin
      mrif.dmemREN <= 1'b0;    // Reset memory read enable
      mrif.dmemWEN <= 1'b0;    // Reset memory write enable
    end else begin
      mrif.dmemREN <= dmemREN_next;   // Set memory read enable
      mrif.dmemWEN <= dmemWEN_next;   // Set memory write enable
    end
  end

endmodule
