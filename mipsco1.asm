.data
    # --- Mensajes---
    msg_grado: .asciiz "Ingrese el grado del polinomio (n): "
    msg_coef:  .asciiz "Ingrese el coeficiente a["
    msg_cierre: .asciiz "]: "
    msg_x:     .asciiz "Ingrese el valor de x (en punto flotante): "
    msg_res:   .asciiz "El resultado P(x) es: "

.text
.globl main

main:
    # ----------------------------------------------------
    # 1. Grado de polinomio(n)
    # ----------------------------------------------------
    li   $v0, 4
    la   $a0, msg_grado
    syscall

    li   $v0, 5          
    syscall
    move $s0, $v0        

    # ----------------------------------------------------
    # 2. Memoria reservada para los (n+1) coeficientes
    # ----------------------------------------------------
    addi $t0, $s0, 1     
    li   $a1, 4          # Cada coeficiente es un entero de 4 bytes
    mult $t0, $a1
    mflo $a0             # Bytes totales en $a0
    
    li   $v0, 9          # Syscall para reservar memoria (sbrk)
    syscall
    move $s1, $v0        # Guardar la dirección base del array de coeficientes en $s1

    # ----------------------------------------------------
    # 3. Bucle para leer los n+1 coeficientes
    # ----------------------------------------------------
    li   $t0, 0         
    move $t1, $s1        

loop_leer_coef:
    # Condición de salida: si i > n, terminar
    bgt  $t0, $s0, fin_leer_coef 

    # Imprimir mensaje "Ingrese el coeficiente a[i]: "
    li   $v0, 4
    la   $a0, msg_coef
    syscall
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, msg_cierre
    syscall

    # Leer el coeficiente entero
    li   $v0, 5
    syscall
    
    # Guardar el coeficiente leído en la memoria
    sw   $v0, 0($t1)

    # Actualizar punteros para la siguiente iteración
    addi $t0, $t0, 1     
    addi $t1, $t1, 4     
    j    loop_leer_coef

fin_leer_coef:
    # ----------------------------------------------------
    # 4. Pedir el valor de x (punto flotante)
    # ----------------------------------------------------
    li   $v0, 4
    la   $a0, msg_x
    syscall
    
    li   $v0, 6          # Syscall para leer float
    syscall
    # El valor de x ya está en el registro $f0 del coprocesador

    # ----------------------------------------------------
    # 5. Evaluar el polinomio usando el Método de Horner
    # ----------------------------------------------------
    # Puntero al último coeficiente a[n]
    move $t0, $s1        # Dirección base
    mul  $t1, $s0, 4     # Offset = n * 4
    add  $t0, $t0, $t1   # Dirección de a[n]

    # Cargar a[n] (es un entero)
    lw   $t1, 0($t0)

    # Convertir a[n] a flotante y guardarlo como el resultado inicial en $f1
    mtc1 $t1, $f1        # Mover el entero al coprocesador
    cvt.s.w $f1, $f1     # Convertir a flotante (resultado = a[n])
    
    # Bucle de Horner: i va desde (n-1) hasta 0
    # $s0 tiene n. Empezamos con i = n-1
    addi $t2, $s0, -1    # i = n-1

loop_horner:
    # Condición de salida: si i < 0, terminar
    blt  $t2, $zero, fin_horner

    # resultado = resultado * x
    mul.s $f1, $f1, $f0  # $f1 = $f1 * $f0 (x)

    # Puntero al coeficiente a[i]
    move $t0, $s1        # Dirección base
    mul  $t1, $t2, 4     # Offset = i * 4
    add  $t0, $t0, $t1   # Dirección de a[i]

    # Cargar a[i] (entero)
    lw   $t1, 0($t0)

    # Convertir a[i] a flotante y guardarlo en $f2
    mtc1 $t1, $f2
    cvt.s.w $f2, $f2
    
    # resultado = resultado + a[i]
    add.s $f1, $f1, $f2
    
    # Actualizar contador
    addi $t2, $t2, -1    # i--
    j    loop_horner

fin_horner:
    # ----------------------------------------------------
    # 6. Imprimir el resultado final
    # ----------------------------------------------------
    li   $v0, 4
    la   $a0, msg_res
    syscall

    # Mover el resultado final ($f1) al registro de impresión ($f12)
    mov.s $f12, $f1
    
    li   $v0, 2          # Syscall para imprimir float
    syscall

    # ----------------------------------------------------
    # 7. Terminar el programa
    # ----------------------------------------------------
    li   $v0, 10
    syscall
