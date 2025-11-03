.global __start

.data
array0:     .word 5, 7, 45, 14, 2, 32

.text
__start:    la      a0,array0
            jal     arradd

doom:       li      a0,10
            j       done

arradd:     li      t0,0
            lw      t1,0(a0)
loop:       addi    t1,-1
            bltz    t1,end
            lw      t2,4(a0)
            add     t0,t2
            addi    a0,4
            j       loop
end:        mv      a0,t0
            ret

done:       nop
