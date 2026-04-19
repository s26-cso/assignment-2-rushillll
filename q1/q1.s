.set VAL,         0
.set LEFT,        8
.set RIGHT,       16
.set SIZEOF_NODE, 24

.section .text

.globl make_node

make_node:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    sd      s0, 0(sp)

    mv      s0, a0             # input val in s0
    li      a0, SIZEOF_NODE    # size = 24 bytes
    call    malloc             # memory for node

    sw      s0, VAL(a0)        # node->val = val
    sd      zero, LEFT(a0)     # node->left = NULL
    sd      zero, RIGHT(a0)    # node->right = NULL

    ld      ra, 8(sp)
    ld      s0, 0(sp)
    addi    sp, sp, 16
    ret


.globl insert

insert:

    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)         # save root
    sd      s1, 8(sp)          # save val

    mv      s0, a0             # s0 = root
    mv      s1, a1             # s1 = val

    bnez    s0, insertcmp      # root null check
    mv      a0, s1             # else base case, create node
    call    make_node           # ret newnode
    j       insertret

insertcmp:

    lw      t0, VAL(s0)        # t0 = root->val
    beq     s1, t0, insertdone # val == root->val
    blt     s1, t0, insertleft # val < root->val

    ld      a0, RIGHT(s0)      # a0 = root->right
    mv      a1, s1             # pass val
    call    insert             # recurse right
    sd      a0, RIGHT(s0)      # root->right = returned node
    j       insertdone

insertleft:
    ld      a0, LEFT(s0)       # a0 = root->left
    mv      a1, s1             # pass val
    call    insert             # recurse left
    sd      a0, LEFT(s0)       # root->left = returned node

insertdone:
    mv      a0, s0             # return root

insertret:
    ld      ra, 24(sp)
    ld      s1, 8(sp)
    ld      s0, 16(sp)
    addi    sp, sp, 32
    ret


.globl get

get:
    mv      t0, a0             # t0 = root ptr
    mv      t1, a1             # t1 = target val

getloop:
    beqz    t0, getdone        # NULL check
    lw      t2, VAL(t0)        # t2 = curr->val
    beq     t1, t2, getfound   # equal
    blt     t1, t2, getleft    # target < curr->val
    ld      t0, RIGHT(t0)      # else go right
    j       getloop

getleft:
    ld      t0, LEFT(t0)       # move 2 left child
    j       getloop

getfound:
    mv      a0, t0             # return node ptr
    ret

getdone:
    li      a0, 0              # return NULL
    ret


.globl getAtMost

getAtMost:
    mv      t0, a1             # t0 = root ptr
    mv      t1, a0             # t1 = target val
    li      t2, -1             # best = -1 default

getAtMostloop:
    beqz    t0, getAtMostdone  # NULL
    lw      t3, VAL(t0)        # t3 = curr->val
    bgt     t3, t1, getAtMostleft # curr > target

    mv      t2, t3             # update best to curr val
    ld      t0, RIGHT(t0)      # go right to check if closer exists
    j       getAtMostloop

getAtMostleft:
    ld      t0, LEFT(t0)       # go left
    j       getAtMostloop

getAtMostdone:
    mv      a0, t2             # return best val
    ret
