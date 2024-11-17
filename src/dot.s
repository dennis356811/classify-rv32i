.import multi.s
.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  

    li t0, 0            
    li t1, 0 
    # calculate stride 
    slli a3, a3, 2
    slli a4, a4, 2        
loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation
    # t0 : sum
    # t1 : currently processed index
    # t2 : currently processed value of array1
    # t3 : currently processed value of array2
    lw t2, 0(a0)
    lw t3, 0(a1)

    addi sp, sp, -36
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw t0, 24(sp)
    sw t1, 28(sp)
    sw t3, 32(sp)

    mv a0, t2
    mv a1, t3

    jal multi

    mv t2, a0

    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    lw t0, 24(sp)
    lw t1, 28(sp)
    lw t3, 32(sp)
    addi sp, sp, 36

    # mul t2, t2, t3

    add t0, t2, t0
    add a0, a0, a3
    add a1, a1, a4
    addi t1, t1, 1
    j loop_start
loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
