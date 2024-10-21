`include "cpu_types_pkg.vh"
`include "ALU_if.vh"

module ALU (
    alu_if.alu aluif
);
    // Import the ALU operation type from cpu_types_pkg
    import cpu_types_pkg::*;

    always_comb begin
        case (aluif.op) 
            ALU_AND:  aluif.out = aluif.a & aluif.b;
            ALU_OR:   aluif.out = aluif.a | aluif.b;
            ALU_XOR:  aluif.out = aluif.a ^ aluif.b;
            ALU_SLL:  aluif.out = aluif.a << aluif.b[4:0];
            ALU_SRL:  aluif.out = aluif.a >> aluif.b[4:0];
            ALU_SRA:  aluif.out = $signed(aluif.a) >>> aluif.b[4:0];
            ALU_ADD:  aluif.out = $signed(aluif.a) + $signed(aluif.b);
            ALU_SUB:  aluif.out = $signed(aluif.a) - $signed(aluif.b);
            ALU_SLT:  aluif.out = ($signed(aluif.a) < $signed(aluif.b)) ? 32'b1 : 32'b0; // signed less than
            ALU_SLTU: aluif.out = (aluif.a < aluif.b) ? 32'b1 : 32'b0; // unsigned less than
            default:  aluif.out = 32'b0; // Default case
        endcase

        // Determine zero, negative, and overflow flags
        aluif.zero = (aluif.out == 32'b0) ? 1'b1 : 1'b0;
        aluif.neg = aluif.out[31];
        aluif.overflow = ((aluif.op == ALU_ADD && (aluif.a[31] == aluif.b[31]) && (aluif.out[31] != aluif.a[31])) ||
                          (aluif.op == ALU_SUB && (aluif.a[31] != aluif.b[31]) && (aluif.out[31] != aluif.a[31]))) ? 1'b1 : 1'b0;
    end
endmodule