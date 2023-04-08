// jalr test 2
// This test has jalr jumping to an ealier part of the program and sets r7 to 0xa
lbi r0, 0x0            // r0 used for jump address calculation
lbi r1, 0xfd        // r1 acts as a loop counter
lbi r4, 12
nop
nop
nop
nop
nop
addi r1, r1, 0x01
nop
nop
nop
nop
nop
slbi r4, 98
nop
nop
nop
nop
nop
bgez r1, .done        //after 3 total executions of add, go to halt
nop
nop
nop
nop
nop
jalr r0, 0x4
nop
nop
nop
nop
nop
.done:
halt