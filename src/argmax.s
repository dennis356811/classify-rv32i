.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1
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
handle_error:
    li a0, 36
    j exit
