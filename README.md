---
title: 'Assignment 2: Classify'

---

# Assignment 2: Classify
## Result
After excute ```bash ./test.sh all```
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 118.800s

OK
```

## Task 1: ReLU
I use a branch to check whether the value is greater than zero. If it is, nothing is done, and the index and address are incremented to proceed to the next loop iteration. If not, 0 is stored at that address.
```cmake
loop_start:
# TODO: Add your own implementation
    beq t1, a1, loop_end        # check if t1 = a1 (length of array)
    lw t2, 0(a0)                # load value from @a0 to t2
    bge t2, x0, greater_zero    # if t2 >= 0, value remains (don't do anything)
    sw x0, 0(a0)                # if t2 < 0, replace @a0 by 0
greater_zero:
    addi t1, t1, 1              # number of checked value add 1 
    addi a0, a0, 4              # check next indexed value
    j loop_start          
loop_end:
    jalr x0, ra, 0              # return to caller
```

## Task 2: Argmax
I use three registers to record the currently found maximum value, the index corresponding to the maximum value, and the index currently being checked. A branch is used to determine whether the value at the current index is greater than the current maximum value. If it is, the maximum value is updated. If not, the index and address are incremented to check the value of the next index.
```cmake
loop_start:
# TODO: Add your own implementation
    # t0 : max value have found
    # t1 : max-valued index have found
    # t2 : the index currently checking
    beq t2, a1, loop_end        # check if t2 = a1 (length of array)
    addi a0, a0, 4              # get next indexed address 
    lw t3, 0(a0)                # get next indexed value
    ble t3, t0, less_max        # if value is less equal than the max value we have found, nothing change
    mv t0, t3                   # replace the max value by newer max value
    mv t1, t2                   # replace the max-valued index by newer max-valued index
less_max:
    addi t2, t2, 1              # number of checked value add 1 
    j loop_start
loop_end:
    mv a0, t1                   # set return value by t1 
    jalr x0, ra, 0              # return to caller
```

## Task 3: Multiplication
I additionally implemented a program called ```multi.s``` to replace the ```mul``` instruction. The principle is the same as the shift-and-add method used in a previous quiz, and I used clz to enhance its efficiency.
```cmake
# multi.s
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
```
## Other Task:
For the remaining tasks, such as ``dot product``, ``matrix multiplication``, and ``classify``, the main work is essentially replacing the original ``mul`` instruction with my custom ``multi.s``. However, it is important to pay attention to the calling convention. I spent a lot of time fixing bugs related to this aspect.