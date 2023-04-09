// Testing whether negative immediates are handled correctly in a few situations.

lbi r0, 0
lbi r1, 0
addi r0, r0, 10
addi r0, r0, -1
addi r0, r0, -9
addi r1, r1, 10
j 2
halt
beqz r0, -4
addi r1, -9
j -3