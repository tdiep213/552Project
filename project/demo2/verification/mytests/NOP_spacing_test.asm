// For several instruction types, 
// run the same instruction repeatedly 
// with decreasing NOPS, to determine where Hazards
// are not being stalled away.
// As of writing,  one nop and zero nops are not enough space between instructions.
// We must find the source of instruction delay.
lbi r0, 0
nop
nop
nop
nop
nop
lbi r1, 1
nop
nop
nop
nop
lbi r2, 2
nop
nop
nop
lbi r3, 3
nop
nop
lbi r4, 4
nop
lbi r5, 5
lbi r6, 6
halt