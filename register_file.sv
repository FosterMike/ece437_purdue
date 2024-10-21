`include "register_file_if.vh"

module register_file(
    input logic clk, n_rst, register_file_if.rf rfif
);

    reg [31:0][31:0] regs, next_regs;

    always_ff @(negedge clk, negedge n_rst) begin
        if (!n_rst) begin
            regs <= '0;
        end
        else begin
            regs <= next_regs;
        end
    end
    always_comb begin
        next_regs[0] = '0;
        next_regs[31:1] = regs[31:1];

        if (rfif.WEN) begin
            next_regs[rfif.wsel] = rfif.wdat;
            next_regs[0] = '0;
        end


        rfif.rdat1 = regs[rfif.rsel1];
        rfif.rdat2 = regs[rfif.rsel2];
    end
endmodule