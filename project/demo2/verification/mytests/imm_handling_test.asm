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