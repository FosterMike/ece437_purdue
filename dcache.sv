module dcache (
  input logic        CLK,           // Clock signal
  input logic        nRST,          // Reset signal
  datapath_cache_if.cache dcif,     // Cache interface from datapath
  caches_if.dcache   cif            // Cache interface to memory control
);

  // Cache specifications
  parameter CACHE_SIZE_BYTES = 128; // Total size of cache in bytes
  parameter BLOCK_SIZE_WORDS = 2;   // 2 words per block
  parameter WAYS = 2;               // 2-way associative

  // Cache data memory
  logic [31:0] cache_data[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0][BLOCK_SIZE_WORDS-1:0];
  logic [31:0] n_cache_data[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0][BLOCK_SIZE_WORDS-1:0];
  logic [31:0] cache_tag[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0];
  logic        valid_bits[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0];
  logic        dirty_bits[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0];
  logic        n_dirty_bits[WAYS-1:0][CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0];

  // LRU (Least Recently Used) bits to manage two-way associative cache
  logic        lru[CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS-1:0]; // One bit per set for 2-way cache

  // Cache hit and other signals
  logic        cache_hit;
  logic        cache_miss;
  logic        write_back_required;
  logic [31:0] hit_counter;

  logic        eviction_needed;
  logic [31:0] evicted_data_word0;
  logic [31:0] evicted_data_word1;

  logic [31:0] evicted_tag;
  logic [1:0]  write_back_word;

  // Temporary variables for cache indexing
  logic [31:0] index;
  logic [31:0] tag;
  logic [31:0] offset;
  logic        way_hit[WAYS-1:0];   // Indicates hit in a specific way
  logic        eviction_way;
  assign eviction_way = lru[index];
  // Address parsing
  assign index  = dcif.dmemaddr[9:2];   // Cache index (assuming 32-bit address, index uses bits 9 to 2)
  assign tag    = dcif.dmemaddr[31:10]; // Cache tag (upper bits)
  assign offset = dcif.dmemaddr[1:0];   // Offset within the block (2 words per block)

  // Hit detection logic
  always_comb begin
    cache_hit = 0;
    cache_miss = 1;
    way_hit[0] = (valid_bits[0][index] && (cache_tag[0][index] == tag));
    way_hit[1] = (valid_bits[1][index] && (cache_tag[1][index] == tag));
    if (way_hit[0] || way_hit[1]) begin
      cache_hit = 1;
      cache_miss = 0;
    end
  end

  // LRU replacement policy for two-way associative cache
  always_ff @(negedge CLK, negedge nRST) begin
    if (!nRST) begin
      for (int j = 0; j < CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS; j++) begin
          lru[j] <= '0;
      end
    end
    else begin
      if (way_hit[0]) begin
        lru[index] <= 1; // Mark way 0 as recently used
      end else if (way_hit[1]) begin
        lru[index] <= 0; // Mark way 1 as recently used
      end
    end
  end

  // Cache read and write operations, and hit counting
  always_ff @(posedge CLK or negedge nRST) begin
    if (!nRST) begin
      hit_counter <= 32'd0;          // Reset hit counter
      write_back_word <= 2'b0;
      for (int i = 0; i < WAYS; i++) begin
        for (int j = 0; j < CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS; j++) begin
            for (int k = 0; k < BLOCK_SIZE_WORDS; k++) begin
                cache_data[i][j][k] <= 32'b0;   // Initialize cache data
                cache_tag[i][j][k] <= 32'b0;
            end
          valid_bits[i][j] <= 1'b0;
          dirty_bits[i][j] <= 1'b0;
        end
      end

    end else begin

      if (dcif.halt) begin
        // Invalidate cache blocks on halt
        write_back_word <= 2'b0;
        for (int i = 0; i < WAYS; i++) begin
          for (int j = 0; j < CACHE_SIZE_BYTES/BLOCK_SIZE_WORDS; j++) begin
            valid_bits[i][j] <= 1'b0;
            dirty_bits[i][j] <= 1'b0;
          end
        end
      end 
      else if (eviction_needed) begin
          // Write both words of the dirty block back to memory
          if (write_back_word == 2) begin
            write_back_word <= 2'b0;
            dirty_bits[eviction_way][index] <= 0;
          end
          else if (~cif.dwait) 
              write_back_word <= write_back_word + 1;



      end
      else if (dcif.dmemREN && ~cif.dwait && cache_miss) begin
          // Cache miss: Data will be loaded from external memory, so mark the cache line as valid
          // Choose the way to store the data based on LRU policy
              if (lru[index]) begin
                  // Store in way 1 (based on LRU)
                  cache_data[1][index][offset] <= cif.dload;
                  cache_tag[1][index] <= tag;
                  valid_bits[1][index] <= 1'b1;  // Mark way 1 as valid
                  dirty_bits[1][index] <= 1'b0;  // Clear dirty bit on new data load
              end else begin
                  // Store in way 0 (based on LRU)
                  cache_data[0][index][offset] <= cif.dload;
                  cache_tag[0][index] <= tag;
                  valid_bits[0][index] <= 1'b1;  // Mark way 0 as valid
                  dirty_bits[0][index] <= 1'b0;  // Clear dirty bit on new data load
              end
      end
      else if (dcif.dmemWEN) begin
  // Cache write operation
        if (cache_hit) begin
            if (way_hit[0]) begin
            cache_data[0][index][offset] <= dcif.dmemstore;
            dirty_bits[0][index] <= 1'b1;
            end else if (way_hit[1]) begin
            cache_data[1][index][offset] <= dcif.dmemstore;
            dirty_bits[1][index] <= 1'b1;
            end
        end else begin
            // Cache miss: forward write to memory control
            if (lru[index]) begin
                // Store in way 1 (based on LRU)
                cache_data[1][index][offset] <= dcif.dmemstore;
                cache_tag[1][index] <= tag;
                valid_bits[1][index] <= 1'b1;  // Mark way 1 as valid
                dirty_bits[1][index] <= 1'b1;  // Clear dirty bit on new data load
            end else begin
                // Store in way 0 (based on LRU)
                cache_data[0][index][offset] <= dcif.dmemstore;
                cache_tag[0][index] <= tag;
                valid_bits[0][index] <= 1'b1;  // Mark way 0 as valid
                dirty_bits[0][index] <= 1'b1;  // Clear dirty bit on new data load
            end
        end
      end
      end
    end
  
  always_comb begin
    eviction_needed = 1'b0;
    evicted_data_word0 = 32'b0;
    evicted_data_word1 = 32'b0;
    evicted_tag = 32'b0;

  if(cache_miss && valid_bits[eviction_way][index] && dirty_bits[eviction_way][index]) begin
      eviction_needed = 1'b1;
      evicted_data_word0 = cache_data[eviction_way][index][0];
      evicted_data_word1 = cache_data[eviction_way][index][1];

      evicted_tag = cache_tag[eviction_way][index];
    end

  end


  // Fully combinational data path for dmemload
  always_comb begin
    dcif.dmemload = 32'b0;
    cif.dREN = 1'b0;
    cif.daddr = 32'b0;
    cif.dWEN = 1'b0;
    cif.dstore = '0;
    n_cache_data = cache_data;
    n_dirty_bits = dirty_bits;

    if (dcif.dmemaddr == 32'h3100 && dcif.dmemREN) begin
      dcif.dmemload = hit_counter;
    end
    if (dcif.dmemREN) begin
      if (cache_hit) begin
        // Cache hit: read from cache memory
        dcif.dmemload = way_hit[0] ? cache_data[0][index][offset] : cache_data[1][index][offset];
      end else begin
        // Cache miss: read from external memory (via cif)
        dcif.dmemload = cif.dload;
        cif.dREN = 1'b1;
        cif.daddr = dcif.dmemaddr;
      end
    end

    if (write_back_word == 0) begin
      cif.dWEN = 1'b1;
      cif.daddr = {evicted_tag, index, 2'b00}; // Address for word 0
      cif.dstore = evicted_data_word0;        // Write first word
    end else if (write_back_word == 1) begin
      cif.dWEN = 1'b1;
      cif.daddr = {evicted_tag, index, 2'b01}; // Address for word 1
      cif.dstore = evicted_data_word1;        // Write second word
    end
  end

  // dhit signal: triggered by cache_hit or external memory ready
  always_comb begin
    dcif.dhit = cache_hit ? 1 : (dcif.dmemREN|dcif.dmemWEN) ? ~cif.dwait : 0;
  end

  // Write the hit counter to address 0x3100 for simulator validation
  always_ff @(posedge CLK, negedge nRST) begin
    if (!nRST) 
      hit_counter <= 0;
    else begin
      if(dcif.halt)
        hit_counter <= 0;
      else if (cache_hit)
        hit_counter <= hit_counter + 1;
    end
  end
endmodule
