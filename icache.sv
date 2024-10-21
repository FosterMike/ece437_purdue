module icache (
  input logic        CLK,           // Clock signal
  input logic        nRST,          // Reset signal
  datapath_cache_if.cache dcif,     // Cache interface from datapath
  caches_if.icache   cif            // Cache interface to memory control
);

  // Cache specifications
  parameter CACHE_SIZE_BYTES = 64;  // 64 bytes total size
  parameter BLOCK_SIZE_WORDS = 1;   // 1 word per block
  parameter NUM_BLOCKS = CACHE_SIZE_BYTES / (BLOCK_SIZE_WORDS * 4);  // Number of blocks (direct-mapped)

  // Cache data memory
  logic [31:0] cache_data[NUM_BLOCKS-1:0];      // Store cache data (1 word per block)
  logic [31:0] cache_tag[NUM_BLOCKS-1:0];       // Store cache tags
  logic        valid_bits[NUM_BLOCKS-1:0];      // Store valid bits

  // Cache hit and other signals
  logic        cache_hit;
  logic        cache_miss;
  logic [31:0] hit_counter;

  // Temporary variables for cache indexing
  logic [31:0] index;
  logic [31:0] tag;
  logic [31:0] offset;

  // Address parsing (use instruction memory address signals)
  assign index  = dcif.imemaddr[7:2];   // Cache index (assuming 32-bit address, index uses bits 7 to 2)
  assign tag    = dcif.imemaddr[31:8];  // Cache tag (upper bits)
  assign offset = dcif.imemaddr[1:0];   // Offset within the word (ignored as it's a direct-mapped cache with 1 word/block)

  // Hit detection logic
  always_comb begin
    cache_hit = 0;
    cache_miss = 1;
    if (valid_bits[index] && (cache_tag[index] == tag)) begin
      cache_hit = 1;
      cache_miss = 0;
    end
  end

  // Cache read operations and hit counting
  always_ff @(posedge CLK or negedge nRST) begin
    if (!nRST) begin
      hit_counter <= 32'd0;          // Reset hit counter
      for (int i = 0; i < NUM_BLOCKS; i++) begin
        cache_data[i] <= 32'b0;      // Initialize cache data
        cache_tag[i] <= 32'b0;       // Initialize cache tags
        valid_bits[i] <= 1'b0;       // Invalidate all cache blocks
      end

    end else begin
      if (dcif.halt) begin
        // Invalidate cache blocks on halt
        for (int i = 0; i < NUM_BLOCKS; i++) begin
          valid_bits[i] <= 1'b0;
        end
      end else if (dcif.imemREN && ~cif.iwait && cache_miss) begin
        // Cache miss: Data will be loaded from external memory, so mark the cache line as valid
        cache_data[index] <= cif.iload;    // Store the loaded data
        cache_tag[index] <= tag;           // Update the tag
        valid_bits[index] <= 1'b1;         // Mark the cache line as valid
      end
    end
  end

  // Fully combinational data path for imemload
  always_comb begin
    dcif.imemload = 32'b0;
    cif.iREN = 1'b0;
    cif.iaddr = 32'b0;

    if (dcif.imemaddr == 32'h3100 && dcif.imemREN) begin
      dcif.imemload = hit_counter;
    end else if (dcif.imemREN) begin
      if (cache_hit) begin
        // Cache hit: read from cache memory
        dcif.imemload = cache_data[index];
      end else begin
        // Cache miss: read from external memory (via cif)
        dcif.imemload = cif.iload;
        cif.iREN = 1'b1;
        cif.iaddr = dcif.imemaddr;
      end
    end
  end

  // ihit signal: triggered by cache_hit or external memory ready
  always_comb begin
    dcif.ihit = cache_hit ? 1 : dcif.imemREN ? ~cif.iwait : 0;
  end

  // Write the hit counter to address 0x3100 for simulator validation
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) 
      hit_counter <= 0;
    else begin
      if (dcif.halt)
        hit_counter <= 0;
      else if (cache_hit)
        hit_counter <= hit_counter + 1;
    end
  end

endmodule
