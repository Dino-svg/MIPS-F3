sub $20, $15, $9
sub $20, $20, $9
add $15, $5, $15
add $15, $9, $15
slt $21, $20, $15
addi $10, $5, 15
ori $12, $6, 0xFF
andi $13, $7, 0xF0
lw $14, 8($0)
sw $15, 12($0)
beq $5, $6, equal
bne $5, $6, not_equal
bgtz $15, greater_zero

# Saltos incondicionales (tipo J)
j target1
jal subroutine

equal:
    add $20, $15, $9 
    j end

not_equal:
    sub $20, $15, $9  
    j end

greater_zero:
    and $21, $7, $8   
    j end

target1:
    or $22, $6, $7   
    j end

subroutine:
    addi $23, $5, 30  
    jr $ra           

end:
    sw $20, 0($0)     