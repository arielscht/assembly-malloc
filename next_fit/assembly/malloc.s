.section .data
    INITIAL_BRK: .quad 0
    LOGICAL_HEAP_END: .quad 0
    SEARCH: .quad 0
    EMPTY_STRING: .string " \n"
    DOUBLE_BREAK_LINE: .string "\n\n"
    HEADER_STRING: .string "################"
    OCCUPIED_STRING: .string "+"
    FREE_STRING: .string "-"

    .equ BRK_SERVICE, 12
    .equ EXIT_SERVICE, 60
    .equ BLOCK_SIZE, 4096

.section .text
.globl iniciaAlocador
.globl finalizaAlocador
.globl alocaMem
.globl liberaMem
.globl imprimeMapa

# Returns the amount of 4Kb blocks necessary to store n bytes
# long int get_blocks(long int bytes);
get_blocks:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp                      # Open stack space to save registers
    movq %rdx, -8(%rbp)                 # Save %rdx
    movq %rcx, -16(%rbp)                # Save %rcx

    movq 16(%rbp), %rax                 # %rax := bytes
    movq $BLOCK_SIZE, %rcx              # %rcx := BLOCK_SIZE
    div %rcx                            # %rax := (int)(bytes / BLOCK_SIZE)
                                        # %rdx := bytes % BLOCK_SIZE
    cmpq $0, %rdx                       # Check if the remainders equals 0
    je end_div_if
    addq $1, %rax
end_div_if:
    movq -8(%rbp), %rdx                 # Restore %rdx
    movq -16(%rbp), %rcx                # Restore %rcx
    addq $16, %rsp                      # Restore stack registers space
    popq %rbp
    ret

# Stores the current brk to a global variable
# void iniciaAlocador();
iniciaAlocador:                            
    pushq %rbp
    movq %rsp, %rbp
    mov $EMPTY_STRING, %rdi
    call printf                         # Print empty string to start the buffer
    movq $0, %rdi                       # %rdi := 0
    movq $BRK_SERVICE, %rax             # Set service to brk
    syscall                             # call brk(0)
    movq %rax, INITIAL_BRK              # INITAL_BRK := brk(0)
    movq %rax, LOGICAL_HEAP_END         # LOGICAL_HEAP_END := brk(0)
    movq %rax, SEARCH                   # SEARCH := brk(0)
    popq %rbp                           
    ret

# Restores the brk to its original value
# void finalizaAlocador();
finalizaAlocador:                              
    pushq %rbp
    movq %rsp, %rbp
    movq INITIAL_BRK, %rdi              # %rdi := INITIAL_BRK
    movq $BRK_SERVICE, %rax             # Set service to brk
    syscall                             # call brk(INITIAL_BRK)
    popq %rbp
    ret

# Frees the memory of the given pointer
# int liberaMem(void *block)
liberaMem:                              
    pushq %rbp
    movq %rsp, %rbp
    movq $0, -16(%rdi)                  # occupied byte := 0
   # movq -16(%rdi), SEARCH
    movq $0, %rax                       # return 0
    popq %rbp                    
    ret

# Allocates n bytes of memory in the heap and returns the memory address
# void *alocaMem(long int bytes);
# %rbx -> addr
# %r8 -> heap_end
# %r9 -> smallest
# %r10 -> smallest_size
# %r11 -> logical_heap_end
# %r12 -> is_occupied
# %r13 -> block_size
# %r14 -> bytes
# %r15 -> temporary
alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $40, %rsp
    movq %rbx, -8(%rbp)                 # Save %rbx
    movq %r12, -16(%rbp)                # Save %r12
    movq %r13, -24(%rbp)                # Save %r13
    movq %r14, -32(%rbp)                # Save %r14
    movq %r15, -40(%rbp)                # Save %r15

    movq %rdi, %r14                # $r14 := bytes

    movq SEARCH, %rbx                   # %rbx := SEARCH
    movq $0, %rdi                       # %rdi := 0
    movq $BRK_SERVICE, %rax             # Set the service to brk
    syscall
    movq %rax, %r8                      # %r8 := brk(0)
    movq $0, %r9                        # %r9 := 0 := NULL
    movq $0, %r10                       # %r10 := 0
    movq LOGICAL_HEAP_END, %r11         # %r11 := logical_heap_end
    

alloc_while:
    cmpq %r11, %rbx                     # Compares logical_heap_end with addr
    jge end_alloc_while                 # Exits the loop
    cmpq $0, %r9                        # Compares smallest with 0 (NULL)
    jne end_alloc_while
        movq (%rbx), %r12               # %r12 := is_occupied
        movq %rbx, %r13                 # %r13 := %rbx
        addq $8, %r13                   # %r13 += 8
        movq (%r13), %r13               # %r13 := block_size

        cmpq $0, %r12                   # Check if block is occupied
        jne end_occupied_if             # Jumps to end_if
            cmpq %r14, %r13             # Compares bytes with block_size
            jl end_occupied_if          # Jumps to end_if
                movq %rbx,  %r9         # smallest := addr
                
end_occupied_if:
    addq %r13, %rbx                     # %rbx += block_size
    addq $16, %rbx                      # %rbx += 16
    jmp alloc_while                     # Jump to loop start
end_alloc_while:

smallest_if:
    cmpq $0, %r9                        # Compares smallest with 0 (NULL)
    jne smallest_else                   # Jumps to else
        movq %r14, %r15                 # %r15 := bytes
        addq $16, %r15                  # %r15 += 16 := new_block_size
        addq %r11, %r15                 # %r15 := new_logical_end
        movq %r15, %r12                 # %r12 := new_logical_end
        addq $16, %r12                  # %r12 += 16 = new_end
        movq %r8, %r13                  # %r13 := heap_end
        cmpq %r8, %r12                  # Compares new_end with heap_end
        jle blocks_else                 # Jumps to else
            subq %r8, %r12              # %r12 := new_end - heap_end = diff
            pushq %r12                  # Stack the function parameter
            call get_blocks             # call get_blocks
            addq $8, %rsp               # restores stack
            movq $BLOCK_SIZE, %r12      # %r12 := BLOCK_SIZE
            imul %rax, %r12             # %r12 := blocks * BLOCK_SIZE
            addq %r12, %r13             # %r13 += blocks * BLOCK_SIZE := new_heap_end
            movq %r13, %rdi             # %rdi := new_heap_end
            pushq %r11                  # Save %r11
            movq $BRK_SERVICE, %rax     # Set service to brk
            syscall
            popq %r11                   # Restore %r11

blocks_else:

        movq $0, (%r15)                 # logical_occupied := 0
        movq %r15, %r12                 # %r12 := new_logical_end
        addq $8, %r12                   # %r12 := logical_size
        movq %r13, %r9                  # %r9 := new_heap_end
        subq $8, %r9                    # %r9 -= 8
        subq %r12, %r9                  # %r9 -= logical_size
        movq %r9, (%r12)                # %r12 := remaining size

        movq $1, (%r11)                 # logical_heap_end := 1
        movq %r11, %r9                  # %r9 := logical_heap_end
        addq $8, %r9                    # %r9 := size pointer
        movq %r14, (%r9)                # size pointer := bytes
        movq %r15, LOGICAL_HEAP_END     # LOGICAL_HEAP_END = new_logical_heap_end
        movq %r11, %rax                 # %rax := logical_heap_end
        addq $16, %rax                  # %rax := logical_heap_end + 16
        movq %r15, SEARCH               # SEARCH := new_heap_end
        jmp end_smallest_if
        
smallest_else:
        movq $1, (%r9)                  # is_occupied := 1
        movq %r9, %rax                  # %rax := smallest
        addq $16, %rax                  # %rax += 16
        movq %r13, SEARCH               # SEARCH = new_logical_end
end_smallest_if:

    movq -8(%rbp), %rbx                 # Restore %rbx
    movq -16(%rbp), %r12                # Restore %r12
    movq -24(%rbp), %r13                # Restore %r13
    movq -32(%rbp), %r14                # Restore %r14
    movq -40(%rbp), %r15                # Restore %r15

    addq $40, %rsp
    popq %rbp
    ret


# Prints the heap allocation map
# void imprimeMapa()
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp
    movq %rbx, -8(%rbp)                 # Save %rbx
    movq %r12, -16(%rbp)                # Save %r12
    movq %r13, -24(%rbp)                # Save %r13

    movq INITIAL_BRK, %rbx              # %rbx := INITIAL_BRK
    movq $0, %rdi                       # %rdi := 0
    movq $BRK_SERVICE, %rax             # Set service to brk
    syscall                 
    movq %rax, %r15                     # %r15 := sbrk(0)

print_while:
    cmpq %r15, %rbx
    jge end_print_while
        movq (%rbx), %r11               # %r11 := is_occupied
        movq %rbx, %r12                 # %r12 := addr
        addq $8, %r12                   # %r12 := addr + 8
        movq (%r12), %r12               # %r12 := block_size

        movq $0, %r13                   # %r13 := 0 // Counter
        movq $16, %r14                  # %r14 := 16 // size of header

        pushq %r11
        mov $HEADER_STRING, %rdi
        call printf
        popq %r11

        movq $0, %r13                   # %r13 := 0 // Counter
print_for_2:
        cmpq %r12, %r13                 # Compares the counter with block_size
        jge end_print_for_2             # Exits for loop
            cmpq $1, %r11               # Check if block is occupied
            jne is_not_occupied         # Jumps to else if it is not ocuppied
            mov $OCCUPIED_STRING, %rdi  # Set the string to print
            jmp end_print_occupied_if   # Jumps to end_if
is_not_occupied:
            mov $FREE_STRING, %rdi      # Set the string to print
end_print_occupied_if:
        pushq %r11
        call printf                     # Print the free space string
        popq %r11
        addq $1, %r13                   # Increments the counter
        jmp print_for_2                 # Jumps to loop start
end_print_for_2:
        addq %r12, %rbx                 # %rbx += block_size
        addq $16, %rbx                  # %rbx += 16
        jmp print_while
end_print_while:

    pushq %r11
    mov $DOUBLE_BREAK_LINE, %rdi
    call printf
    popq %r11

    movq -8(%rbp), %rbx                 # Restore %rbx
    movq -16(%rbp), %r12                # Restore %r12
    movq -24(%rbp), %r13                # Restore %r13

    addq $24, %rsp
    popq %rbp
    ret