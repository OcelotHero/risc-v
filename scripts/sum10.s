.global __sum10

.text
__sum10:    addi    x5, x0, 10
            addi    x6, x0, 0
loop:       add     x6, x6, x5
            addi    x5, x5, -1
            bne     x5, x0, loop
            addi    x5, x6, 10
            add     x7, x5, x6
