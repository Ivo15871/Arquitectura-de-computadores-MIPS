.data
array: .word 5, 2, 8, 1, 9, 3  # Array de ejemplo
size:  .word 6                  # Tamaño del array
msg:   .asciiz "Array ordenado (reverso): "

.text
main:
    la $s0, array               # Puntero al inicio del array
    lw $s1, size                # Tamaño del array
    move $s2, $s1               # Contador para el bucle externo

outer_loop:
    beq $s2, $zero, print_result # Si no hay más elementos, terminar
    move $a0, $s0               # Puntero al inicio del subarray
    move $a1, $s2               # Número de elementos a considerar
    jal min                     # Llamar a procedimiento min
    move $t0, $v0               # Índice del mínimo
    move $t1, $v1               # Valor mínimo

    # Intercambiar el mínimo con el último elemento del subarray
    mul $t2, $t0, 4             # Offset del índice mínimo
    add $t2, $s0, $t2           # Dirección del mínimo
    mul $t3, $s2, 4             # Offset del último elemento
    addi $t3, $t3, -4           # Ajustar al último índice
    add $t3, $s0, $t3           # Dirección del último elemento
    lw $t4, 0($t2)              # Cargar valor mínimo
    lw $t5, 0($t3)              # Cargar valor del último
    sw $t5, 0($t2)              # Guardar último en posición del mínimo
    sw $t4, 0($t3)              # Guardar mínimo en última posición

    addi $s2, $s2, -1           # Reducir el tamaño del subarray
    j outer_loop

min:
    move $t0, $a0               # Puntero al inicio del array
    move $t1, $a1               # Número de elementos
    lw $t2, 0($t0)              # Valor inicial (primer elemento)
    move $t3, $zero             # Índice inicial del mínimo (0)
    move $t4, $t2               # Valor mínimo inicial
    move $t5, $t0               # Dirección del mínimo inicial
    li $t6, 1                   # Contador para el bucle

min_loop:
    beq $t6, $t1, min_done      # Si se recorrió todo, terminar
    addi $t0, $t0, 4            # Siguiente elemento
    lw $t2, 0($t0)              # Cargar siguiente valor
    bge $t2, $t4, skip_update   # Si no es menor, saltar
    move $t4, $t2               # Actualizar mínimo
    move $t5, $t0               # Actualizar dirección del mínimo
    move $t3, $t6               # Actualizar índice del mínimo

skip_update:
    addi $t6, $t6, 1            # Incrementar contador
    j min_loop

min_done:
    sub $t5, $t5, $s0           # Calcular offset desde el inicio
    srl $t5, $t5, 2             # Convertir offset a índice
    move $v0, $t5               # Devolver índice del mínimo
    move $v1, $t4               # Devolver valor mínimo
    jr $ra

print_result:
    la $a0, msg                 # Imprimir mensaje
    li $v0, 4
    syscall

    la $t0, array               # Puntero al array
    lw $t1, size                # Tamaño del array

print_loop:
    beq $t1, $zero, exit        # Si no hay más elementos, salir
    lw $a0, 0($t0)              # Cargar elemento
    li $v0, 1                   # Imprimir entero
    syscall
    li $a0, 32                  # Imprimir espacio
    li $v0, 11
    syscall
    addi $t0, $t0, 4            # Siguiente elemento
    addi $t1, $t1, -1           # Decrementar contador
    j print_loop

exit:
    li $v0, 10                  # Salir
    syscall