.section .data
path:      .string "input.txt"
yesmsg:   .string "Yes\n"
nomsg:    .string "No\n"

.section .bss
.lcomm buf1, 1   # buffer for left char
.lcomm buf2, 1   # buffer for right char

.section .text
.globl main

main:
    addi sp, sp, -40 
    sd ra, 32(sp)      # save return address
    sd s0, 24(sp)      # fd
    sd s1, 16(sp)      # file size
    sd s2, 8(sp)       # left ptr
    sd s3, 0(sp)       # right ptr

    # fd = open("input.txt", O_RDONLY)
    li a0, -100          # AT_FDCWD (current dir)
    la a1, path          # ptr to file path
    li a2, 0             # O_RDONLY
    li a7, 56            # syscall: openat
    ecall
    mv s0, a0            # file descriptor in s0

    # n = lseek(fd, 0, SEEK_END)
    mv a0, s0            # fd
    li a1, 0             # offset = 0
    li a2, 2             # SEEK_END
    li a7, 62            # syscall: lseek
    ecall
    mv s1, a0            # file size in s1

    li s2, 0             # left = 0
    addi s3, s1, -1      # right = n-1

loop:
    bge s2, s3, printyes   # left >= right

    # read left char
    mv a0, s0            # fd
    mv a1, s2            # offset = left
    li a2, 0             # SEEK_SET
    li a7, 62            # lseek
    ecall

    mv a0, s0            # fd
    la a1, buf1          # left char buffer
    li a2, 1             # read byte
    li a7, 63            # read syscall
    ecall

    # read right char
    mv a0, s0            # fd
    mv a1, s3            # offset = right
    li a2, 0             # SEEK_SET
    li a7, 62            # lseek
    ecall

    mv a0, s0            # fd
    la a1, buf2          # right char buffer
    li a2, 1             # read byte
    li a7, 63            # read syscall
    ecall

    # load chars
    la t0, buf1          # buf1 address
    lb t1, 0(t0)         # load left char

    la t0, buf2          # buf2 address
    lb t2, 0(t0)         # load right char

    bne t1, t2, printno  # mismatch

    addi s2, s2, 1       # l++
    addi s3, s3, -1      # r--
    j loop               # next iter

printyes:
    li a0, 1             # stdout fd
    la a1, yesmsg        # ptr to "Yes\n"
    li a2, 4             # len = 4
    li a7, 64            # write syscall
    ecall
    j exit               

printno:
    li a0, 1             # stdout fd
    la a1, nomsg         # ptr to "No\n"
    li a2, 3             # len = 3
    li a7, 64            # write syscall
    ecall

exit:
    li a0, 0             # exit code 0
    li a7, 93            # exit syscall
    ecall