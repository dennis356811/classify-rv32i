.globl multi

.text
# =================================================================
# FUNCTION: Multiplication
#
# Performs operation multiplication c = a * b
# 
# Args:
#   a0 (int): Multiplier
#   a1 (int): Multiplicand
# Returns:
#   a0 (int): result
# =================================================================

multi:
    # Prologue
    # s0 : multiplier
    # s1 : multiplicand
    # s2 : record if multiplier positive
    # s3 : return value / least significant bit
    # s4 : bit counter
    # s5 : accumulator
    addi sp, sp, -28
    sw ra, 0(sp)

    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    # get arguement
    mv s0, a0
    mv s1, a1

    # make multiplier positive
    srai s2, s0, 31
    bge s0, x0, skip_neg
    xor s0, s0, s2
    addi s0, s0, 1
skip_neg:
    # use clz to initialize bit counter
    # caller save
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw a0, 16(sp)

    # pass arguement
    mv a0, s0
    jal ra, clz_bs

    # get return value
    mv s3, a0 

    # Retrieve caller
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw a0, 16(sp)
    addi sp, sp, 20

    li s4, 32
    sub s4, s4, s3

    li s5, 0
shift_and_add_loop:
    beq s4, x0, end_shift_and_add   # Exit if bit count is zero
    andi s3, s0, 1                  # Check least significant bit
    beq s3, x0, skip_add            # Skip add if bit is 0
    add s5, s5, s1                  # Add to accumulator
skip_add:
    srai s0, s0, 1                  # Right shift multiplier
    slli s1, s1, 1                  # Left shift multiplicand
    addi s4, s4, -1                 # Decrease bit counter
    jal  x0, shift_and_add_loop     # Repeat loop
end_shift_and_add:
    xor s5, s5, s2
    andi s2, s2, 1
    add s5, s5, s2

    mv a0, s5

    # Epilogue
    lw ra, 0(sp)

    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
    jalr x0, ra, 0
## function clz: 
## used register: t0 ~ t3, a0
clz_bs:
    add t0, x0, x0                  # int count = 0
    beq a0, x0, x_zero              # if (x == 0): 
    li t1, 0x0000FFFF   
    bgtu a0, t1, check_8            # if (x <= 0x0000FFFF):
    addi t0, t0, 16                 # count += 16
    slli a0, a0, 16                 # x <<= 16
check_8:
    li t1, 0x00FFFFFF   
    bgtu a0, t1, check_4            # if (x <= 0x00FFFFFF):
    addi t0, t0, 8                  # count += 8
    slli a0, a0, 8                  # x <<= 8
check_4:
    li t1, 0x0FFFFFFF   
    bgtu a0, t1, check_2            # if (x <= 0x0FFFFFFF):
    addi t0, t0, 4                  # count += 4
    slli a0, a0, 4                  # x <<= 4
check_2:
    li t1, 0x3FFFFFFF   
    bgtu a0, t1, check_1            # if (x <= 0x0000FFFF):
    addi t0, t0, 2                  # count += 2
    slli a0, a0, 2                  # x <<= 2
check_1:
    li t1, 0x7FFFFFFF   
    bgtu a0, t1, end_clz            # if (x <= 0x0000FFFF):
    addi t0, t0, 1                  # count += 1
    slli a0, a0, 1                  # x <<= 1
end_clz:
    add a0, t0, x0                  # return count
    jalr x0, ra, 0
x_zero:
    li a0, 32                       # return 32
    jalr x0, ra, 0