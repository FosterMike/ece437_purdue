onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Datapath -color Pink /system_tb/CLK
add wave -noupdate -expand -group Datapath -color Pink /system_tb/nRST
add wave -noupdate -expand -group Datapath -color Pink /system_tb/CLK
add wave -noupdate -expand -group Datapath -color Pink /system_tb/nRST
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/imemREN
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/datomic
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dmemREN
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dmemWEN
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/flushed
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate -expand -group Datapath /system_tb/DUT/CPU/DP/branch_taken
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate -expand -group Datapath -color Pink /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate -expand -group IF_ID -color {Medium Spring Green} -radix decimal /system_tb/DUT/CPU/DP/plif/if_id_pc
add wave -noupdate -expand -group IF_ID -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/if_id_instr
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_pc
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_instr
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_rdata1
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_rdata2
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_imm
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_rd
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_aluop
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_alusrc
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_memtoreg
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_memwrite
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_regwrite
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_pctoreg
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_checkOF
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_halt
add wave -noupdate -expand -group ID_EX -color {Violet Red} /system_tb/DUT/CPU/DP/plif/id_ex_branch_t
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_instr
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_pc
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_aluout
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_rdata2
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_rd
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_memtoreg
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_memwrite
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_regwrite
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_pctoreg
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_halt
add wave -noupdate -expand -group EX_MEM /system_tb/DUT/CPU/DP/plif/ex_mem_branch_t
add wave -noupdate -expand -group EX_MEM -color Cyan /system_tb/DUT/CPU/DP/plif/ex_mem_imm
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_instr
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_pc
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_aluout
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_dmemload
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_rd
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_memtoreg
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_regwrite
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_pctoreg
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_imm
add wave -noupdate -expand -group MEM_WB -color {Medium Spring Green} /system_tb/DUT/CPU/DP/plif/mem_wb_halt
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/Instr
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/jump_t
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/RegDst_t
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/RegWen
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/ALUSrc_t
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/ALUOP
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/MemToReg
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/PcToReg
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/MemWrite
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/checkOF
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/branch_t
add wave -noupdate -expand -group control -color {Violet Red} /system_tb/DUT/CPU/DP/cuif/halt
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/WEN
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/wdat
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate -expand -group Register -color Cyan /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/a
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/b
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/out
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/op
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/neg
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/overflow
add wave -noupdate -expand -group ALU -color {Spring Green} /system_tb/DUT/CPU/DP/aluif/zero
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/memREN
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/memWEN
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/memaddr
add wave -noupdate -expand -group Ram -color {Violet Red} /system_tb/DUT/RAM/ramif/memstore
add wave -noupdate /system_tb/DUT/CPU/DP/RF/regs
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/rs1
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/rs2
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/ex_mem_rd
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/ex_mem_regwrite
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/mem_wb_rd
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/mem_wb_regwrite
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/ex_mem_memread
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/stall
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/pc_write
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/if_id_write
add wave -noupdate -expand -group {Hazard Unit} -color {Cornflower Blue} /system_tb/DUT/CPU/DP/hzif/hazard_detected
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/rs1
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/rs2
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/ex_mem_rd
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/mem_wb_rd
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/ex_mem_regwrite
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/mem_wb_regwrite
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/ex_mem_aluout
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/mem_wb_wdata
add wave -noupdate -expand -group {Forwarding Unit} -color Coral /system_tb/DUT/CPU/DP/fwif/forwardA
add wave -noupdate -expand -group {Forwarding Unit} /system_tb/DUT/CPU/DP/fwif/forwardB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {987819 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 357
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {931773 ps} {1192773 ps}
