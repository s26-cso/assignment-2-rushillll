.section .bss
.align 2
arr:    .space 4000
result: .space 4000
stk:    .space 4000

.section .data
fmt_mid: .string "%d "
fmt_end: .string "%d\n"

.section .text
.global main

.extern atoi
.extern printf
.extern exit

main:

    addi    s0, a0, -1   # n = argc - 1 (number of integers, ignoring prog name)
    mv      s1, a1       # argv pointer
    li      s2, 0        # i = 0

arrayloadloop:

    bge     s2, s0, loaddone   # i >= n
    addi    t0, s2, 1          # skip argv[0] cus prog name, idx = i+1
    slli    t0, t0, 3          # ptr size is 8
    add     t0, s1, t0         # addy of argv[i+1]
    ld      a0, 0(t0)          # str ptr
    call    atoi               # str to int

    slli    t0, s2, 2          # int size
    la      t1, arr            # base address of arr
    add     t1, t1, t0         # arr[i]
    sw      a0, 0(t1)          # store int

    addi    s2, s2, 1          # i++
    j       arrayloadloop

loaddone:

    li      s2, 0              # i=0

initloop:

    bge     s2, s0, initdone   # init res arr
    slli    t0, s2, 2
    la      t1, result         # base of res
    add     t1, t1, t0         # result[i]
    li      t2, -1             # default = -1
    sw      t2, 0(t1)          # store -1

    addi    s2, s2, 1          # i++
    j       initloop

initdone:

    li      s3, 0              # stack size = 0
    addi    s2, s0, -1         # i = n-1

stackloop:

    blt     s2, zero, stackdone   # i < 0

    slli    t4, s2, 2
    la      t5, arr               # base of arr
    add     t5, t5, t4            # arr[i]
    lw      t5, 0(t5)             # curr val

poploop:

    beqz    s3, popdone           # stack empty?

    addi    t0, s3, -1            # top idx = stacksize-1
    slli    t0, t0, 2
    la      t1, stk               # base of stack
    add     t1, t1, t0            # stk[top]
    lw      t1, 0(t1)             # idx from stack

    slli    t2, t1, 2
    la      t3, arr               # base of arr
    add     t3, t3, t2            # arr[stk[top]]
    lw      t3, 0(t3)             # value at the index

    bgt     t3, t5, popdone       # greater check

    addi    s3, s3, -1            # pop
    j       poploop

popdone:

    beqz    s3, nores             # stack empty
    addi    t0, s3, -1            # top idx
    slli    t0, t0, 2
    la      t1, stk
    add     t1, t1, t0
    lw      t1, 0(t1)             # closest greater index

    slli    t0, s2, 2
    la      t2, result
    add     t2, t2, t0
    sw      t1, 0(t2)             # store ans

nores:

    slli    t0, s3, 2
    la      t1, stk
    add     t1, t1, t0
    sw      s2, 0(t1)             # push curr idx

    addi    s3, s3, 1             # stacksize++
    addi    s2, s2, -1            # i--
    j       stackloop

stackdone:

    li      s2, 0                 # i =0

printloop:

    bge     s2, s0, printdone     # i >= n

    slli    t0, s2, 2
    la      t1, result
    add     t1, t1, t0
    lw      a1, 0(t1)             # load result[i]

    addi    t0, s0, -1            # last idx = n-1
    beq     s2, t0, lastelem      # last element check

    la      a0, fmt_mid           # print w space
    j       doprint

lastelem:

    la      a0, fmt_end           # print w \n

doprint:

    call    printf                # print result[i]

    addi    s2, s2, 1             # i++
    j       printloop

printdone:

    li      a0, 0
    call    exit