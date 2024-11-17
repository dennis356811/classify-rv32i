.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

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
error:
    li a0, 36          
    j exit          
