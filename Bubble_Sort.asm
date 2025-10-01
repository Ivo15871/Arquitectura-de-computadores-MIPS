.data
array: .word 5, 2, 8, 1, 9, 3  # Array de ejemplo
size:  .word 6                  # Tamaño del array
msg:   .asciiz "Array ordenado (bubble sort): "

.text
main:
    la $a0, array               # Puntero al inicio del array
    lw $t0, size                # Tamaño del array
    mul $t1, $t0, 4             # Calcular offset del final
    add $a1, $a0, $t1           # Puntero al final del array
    jal bubble_sort             # Llamar a bubble sort

    # Imprimir resultado
    la $a0, msg
    li $v0, 4
    syscall
    la $t0, array
    lw $t1, size

print_loop:
    beq $t1, $zero, exit
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    li $a0, 32
    li $v0, 11
    syscall
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j print_loop

bubble_sort:
    addi $sp, $sp, -4           # Guardar $ra
    sw $ra, 0($sp)
    move $t0, $a0               # Puntero al inicio
    move $t1, $a1               # Puntero al final
    li $t2, 0                   # swapped = 0

outer_loop:
    move $t3, $t0               # Puntero al elemento actual
    li $t2, 0                   # Reset swapped

inner_loop:
    addi $t4, $t3, 4            # Siguiente elemento
    bge $t4, $t1, check_swapped # Si se alcanzó el final, verificar
    lw $t5, 0($t3)              # Cargar valor actual
    lw $t6, 0($t4)              # Cargar siguiente valor
    ble $t5, $t6, no_swap       # Si están en orden, no intercambiar
    sw $t6, 0($t3)              # Intercambiar
    sw $t5, 0($t4)
    li $t2, 1                   # Marcar swapped = 1

no_swap:
    move $t3, $t4               # Avanzar al siguiente elemento
    j inner_loop

check_swapped:
    beq $t2, $zero, done        # Si no hubo intercambios, terminar
    j outer_loop

done:
    lw $ra, 0($sp)              # Restaurar $ra
    addi $sp, $sp, 4
    jr $ra

exit:
    li $v0, 10
    syscall