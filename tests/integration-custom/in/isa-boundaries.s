# All required ALU operations with immediate dependencies and signed extremes.
lui t0, 524288
addi t1, x0, -1
addi t2, x0, 31
add a0, t0, t1
sub a0, t1, t0
and a0, t0, t1
or a0, t0, t1
xor a0, t0, t1
sll a0, t1, t2
srl a0, t0, t2
sra a0, t0, t2
slt a0, t0, t1
mul a0, t0, t1
mulh a0, t0, t1
mulhu a0, t0, t1
andi a0, t1, -17
ori a0, t0, 123
xori a0, t1, -2048
slli a0, t1, 31
srli a0, t0, 31
srai a0, t0, 31
slti a0, t0, -1
auipc a0, 1
addi x0, t1, 99
add a0, x0, x0
# High shift-count bits are ignored.
addi t2, x0, 63
sll a0, t1, t2
srl a0, t0, t2
sra a0, t0, t2
# Partial writes preserve other lanes, including signed loads.
addi s0, x0, 256
sw t1, 0(s0)
sb t0, 1(s0)
lw a0, 0(s0)
lb a0, 3(s0)
lbu a0, 3(s0)
sh t0, 2(s0)
lh a0, 2(s0)
lhu a0, 2(s0)
lw a0, 0(s0)
# Taken and not-taken branches, followed by observable wrong-path writes.
beq t0, t1, bad
bne t0, t1, next1
bad: addi a0, x0, -99
next1: blt t0, t1, next2
addi a0, x0, -98
next2: bge t1, t0, next3
addi a0, x0, -97
next3: bltu t0, t1, next4
addi a0, x0, -96
next4: bgeu t1, t0, next5
addi a0, x0, -95
next5: jal ra, target
addi a0, x0, 77
jal x0, done
target: addi t2, ra, 1
jalr x0, t2, 0
addi a0, x0, -94
done:
