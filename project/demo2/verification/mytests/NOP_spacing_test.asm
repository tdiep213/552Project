// For several instruction types, 
// run the same instruction repeatedly 
// with decreasing NOPS, to determine where Hazards
// are not being stalled away.
// As of writing,  one nop and zero nops are not enough space between instructions.
// We must find the source of instruction delay.

// Strangely enough, after adding a second round of instr and nops,
// the lbi instr ran fine, and the last two addi failed instead.
// so I added incrementing nops to the end, and found out
// that our halt is preventing the instructions from finishing the last stages of the program

// however the other complex_tests still fail in the middle of the program, suggesting a secondary form of blockage
// it could be ANY instruction run immediately after another will cause trouble, 
// if it is followed by more than 1 other instruction

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
lbi r2, 2   // for some reason 4 nops needed after this
nop
nop
nop
nop
lbi r3, 3  // but remaining nop spacing fine for this trial
nop
nop
lbi r4, 4
nop
lbi r5, 5
lbi r6, 6
nop
nop
nop
nop
nop

lbi r0, 100
nop
nop
nop
nop
nop
lbi r1, 101
lbi r2, 102
lbi r3, 103
lbi r4, 104
nop
lbi r5, 105
lbi r6, 106

addi r0, r0, 7
nop
nop
nop
nop
nop
addi r1, r1, 8
nop
nop
nop
nop
addi r2, r2, 9
nop
nop
nop
addi r3, r3, 10
nop
nop
addi r4, r4, 11
nop
addi r5, r5, 12
addi r6, r6, 13
nop
nop
nop
halt