// This test will go through each size and extension of immediates
// 5-bit imm, zero-ext
// 5-bit imm, sign-ext
// 8-bit imm, zero-ext
// 8-bit imm, sign-ext
// 11-bit imm, sign-ext
// Operations will include immidate math operations,
// Jumps, Memory, and Branches
// First draft of test will have NOPs to prevent hazards
// from breaking mem based operations
// Later drafts will incorporate important hazard checks

lbi r0, 0
addi r1, r0, 15     // sign-ext 5 bit imm
xori r2, r1, 10     // zero-ext 5 bit imm
st r2, r1, 15       // memory access with sign-ext 5 bit imm
beqz r0, .BLOC      // signed 8 bit branch

.JLOC
halt                // True end

.BLOC:
slbi r3, 64         // zero-ext 8 bit imm
j .JLOC             // signed 11 bit imm
halt                // this should never execute

