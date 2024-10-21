/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

// memory types
`include "cpu_types_pkg.vh"
  // modport cc (
  //           // cache inputs
  //   input   iREN, dREN, dWEN, dstore, iaddr, daddr,
  //           // ram inputs
  //           ramload, ramstate,
  //           // coherence inputs from cache
  //           ccwrite, cctrans,
  //           // cache outputs
  //   output  iwait, dwait, iload, dload,
  //           // ram outputs
  //           ramstore, ramaddr, ramWEN, ramREN,
  //           // coherence outputs to cache
  //           ccwait, ccinv, ccsnoopaddr
  // );

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 1;
always_comb begin
    // Direct assignments converted into conditional logic
    ccif.ramstore = ccif.dstore;

    if (ccif.dREN == 1 || ccif.dWEN == 1) begin
      ccif.ramaddr = ccif.daddr;
    end else begin
      ccif.ramaddr = ccif.iaddr;
    end

    ccif.ramWEN = ccif.dWEN;

    if ((ccif.dREN == 1 || ccif.iREN == 1) && ccif.dWEN != 1) begin
      ccif.ramREN = 1;
    end else begin
      ccif.ramREN = 0;
    end

    // Cache outputs
    if (ccif.iREN) begin
      ccif.iload = ccif.ramload;
    end else begin
      ccif.iload = '0;
    end

    ccif.dload = ccif.ramload;

    if (ccif.ramstate == ACCESS) begin
      if ((ccif.iREN == 1) && (ccif.dWEN != 1) && (ccif.dREN != 1)) begin
        ccif.iwait = 0;
      end else begin
        ccif.iwait = 1;
      end
    end else begin
      ccif.iwait = 1;
    end

    if (ccif.ramstate == ACCESS) begin
      if (ccif.dREN) begin
        ccif.dwait = 0;
      end else if (ccif.dWEN) begin
        ccif.dwait = 0;
      end else begin
        ccif.dwait = 1;
      end
    end else begin
      ccif.dwait = 1;
    end
  end
endmodule

