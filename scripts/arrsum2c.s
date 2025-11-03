.global __start

.data
array0:     .word 5, 7, 45, 14, 2, 32
array1:     .word 4, 13, 26, 2, 9

.text
__start:    la      a0,array0
            c.jal   arradd
            la      a0,array1
            c.jal   arradd

doom:       c.li    a0,10
            c.j     done

arradd:     c.li    t0,0
            lw      t1,0(a0)
loop:       c.addi  t1,-1
            bltz    t1,end
            lw      t2,4(a0)
            c.add   t0,t2
            c.addi  a0,4
            c.j     loop
end:        c.mv    a0,t0
            c.jr    x1

done:       c.nop
