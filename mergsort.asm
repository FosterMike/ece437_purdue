#----------------------------------------------------------
# RISC-V Assembly
#----------------------------------------------------------
#Mergesort for benchmarking
#Optimized for 512 bit I$ 1024 bit D$
#Author Adam Hendrickson ahendri@purdue.edu

org 0x0000
 ori   $8, $0, 0xFFC
  ori   $2, $0, 0xFFC
  nop
  lui $3, 0xffff7  
  nop
 sub $2, $2, $3
 sub $8, $8, $3
 nop
 lui $3, 0x00007
 nop
 add $2, $2, $3
 add $8, $8, $3
 nop
  ori   $12, $0, data
  nop
  lw    $24, size($0)
  nop
  ori   $6, $0, 1
  srl  $13,$24,$6
  or    $9, $0, $12
  or    $18, $0, $13
  jal   insertion_sort
 ori   $6, $0, 1
  srl  $5,$24,$6
  sub  $13, $24, $5
  ori   $6, $0, 2
  sll  $5,$5,$6
  ori   $12, $0, data
  add  $12, $12, $5
  or    $19, $0, $12
  or    $20, $0, $13
  jal   insertion_sort
 or    $12, $0, $9
  or    $13, $0, $18
  nop
  or    $14, $0, $19
  nop
  or    $15, $0, $20
  nop
  ori   $5, $0, sorted
  nop
  
  // push  $5
    addi $2, $2, -4
    nop
    sw $5, 0($2)
  
  jal   merge
 addi $2, $2, 4
  halt



#void insertion_sort(int* $a0, int $a1)
# $a0 : pointer to data start
# $a1 : size of array
#--------------------------------------
insertion_sort:
nop
 ori   $5, $0, 4
  ori   $7, $0, 2
  nop
  sll  $6,$13,$7
is_outer:
 sltu  $4, $5, $6
  beq   $4, $0, is_end
  add  $31, $12, $5
    nop
  lw    $30, 0($31)
    nop
is_inner:
 beq   $31, $12, is_inner_end
    nop
  lw    $16, -4($31)
    nop
  slt   $4, $30, $16
  beq   $4, $0, is_inner_end
    nop
  sw    $16, 0($31)
    nop
  addi $31, $31, -4
  j     is_inner
is_inner_end:
 nop
 sw    $30, 0($31)
 nop
  addi $5, $5, 4
  j     is_outer
is_end:
 jr    $1
#--------------------------------------

#void merge(int* $a0, int $a1, int* $a2, int $a3, int* dst)
# $a0 : pointer to list 1
# $a1 : size of list 1
# $a2 : pointer to list 2
# $a3 : size of list 2
# dst [$sp+4] : pointer to merged list location
#--------------------------------------
merge:
 nop
 lw    $5, 0($2)
 nop
m_1:
 bne   $13, $0, m_3
m_2:
 bne   $15, $0, m_3
  j     m_end
m_3:
 beq   $15, $0, m_4
  beq   $13, $0, m_5
  nop
  lw    $6, 0($12)
  nop
  lw    $7, 0($14)
  nop
  slt   $4, $6, $7
  beq   $4, $0, m_3a
  nop
  sw    $6, 0($5)
  nop
  addi $5, $5, 4
  addi $12, $12, 4
  addi $13, $13, -1
  nop
  j     m_1
m_3a:
 nop
 sw    $7, 0($5)
 nop
  addi $5, $5, 4
  addi $14, $14, 4
  addi $15, $15, -1
  j     m_1
m_4:  #left copy
 nop
 lw    $6, 0($12)
  nop
  sw    $6, 0($5)
  nop
  addi $5, $5, 4
  addi $13, $13, -1
  addi $12, $12, 4
  nop
  beq   $13, $0, m_end
  j     m_4
m_5:  # right copy
 lw    $7, 0($14)
  nop
  sw    $7, 0($5)
  nop
  addi $5, $5, 4
  addi $15, $15, -1
  addi $14, $14, 4
  nop
  beq   $15, $0, m_end
  j     m_5
m_end:
 jr    $1
#--------------------------------------


org 0x300
size:
cfw 64
data:
cfw 90
cfw 81
cfw 51
cfw 25
cfw 80
cfw 41
cfw 22
cfw 21
cfw 12
cfw 62
cfw 75
cfw 71
cfw 83
cfw 81
cfw 77
cfw 22
cfw 11
cfw 29
cfw 7
cfw 33
cfw 99
cfw 27
cfw 100
cfw 66
cfw 61
cfw 32
cfw 1
cfw 54
cfw 4
cfw 61
cfw 56
cfw 3
cfw 48
cfw 8
cfw 66
cfw 100
cfw 15
cfw 92
cfw 65
cfw 32
cfw 9
cfw 47
cfw 89
cfw 17
cfw 7
cfw 35
cfw 68
cfw 32
cfw 10
cfw 7
cfw 23
cfw 92
cfw 91
cfw 40
cfw 26
cfw 8
cfw 36
cfw 38
cfw 8
cfw 38
cfw 16
cfw 50
cfw 7
cfw 67

org 0x500
sorted: