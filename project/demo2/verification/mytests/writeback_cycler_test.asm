// Tests writeback safety and register selection,
// by cycling through each RegAddr option for writeback operations
// can be expanded later to verify hazard protection works correctly.
// Also indirectly tests some jump operations

lbi r0, 64      // get some values to play with
lbi r1, 32
lbi r3, 16

add r4, r3, r2  // test Rd = Instr[4:2]
subi r4, r4, 48 // test Rd = Instr[7:5]
st r1, r0, 0    // test Rd used as a value loc and Rs as part of an address

jal r1, .JLOC   // jump and store PC+2 in R7
stu r3, r0, 64  // use Rd as a source, and save mem address at Rs
halt            // true end

.JLOC
jr r7, 0        // return the value we just saved
halt