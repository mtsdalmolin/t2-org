#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M        O                           #
.text
main:
# corpo do procedimento
            # mensagens iniciais do programa
            la       $a0, msgInicial
            li       $v0, 4
            syscall
            
            la       $a0, separacao
            li       $v0, 4
            syscall
            
            la       $a0, msgInforme
            li       $v0, 4
            syscall
            
            la       $a0, msgA
            li       $v0, 4
            syscall
            
            # pede para o usuario os valores de A, B e C
            li       $v0, 5  # "A"
            syscall
            
            mtc1     $v0, $f4  # move o valor de $t0 para $f6
            cvt.d.w  $f4, $f4  # converte 3 PI para 3 PF
            la       $t1, A
            sdc1     $f4, 0($t1)  # guarda valor de "A" na memoria
            
            la       $a0, msgB
            li       $v0, 4
            syscall
            
            li       $v0, 5  # "B"
            syscall
            mtc1     $v0, $f4  # move o valor de $t0 para $f6
            cvt.d.w  $f4, $f4  # converte 3 PI para 3 PF
            la       $t1, B
            sdc1     $f4, 0($t1)  # guarda valor de "B" na memoria
            
            la       $a0, msgC
            li       $v0, 4
            syscall
            
            li       $v0, 5  # "C"
            syscall
            mtc1     $v0, $f4  # move o valor de $t0 para $f6
            cvt.d.w  $f4, $f4  # converte 3 PI para 3 PF
            la       $t1, C
            sdc1     $f4, 0($t1)  # guarda valor de "C" na memoria
            
            la       $t0, A
            ldc1     $f4, 0($t0)  # $f4 <- valor de A
            
            la       $t0, B
            ldc1     $f6, 0($t0)  # $f6 <- valor de B
            
            la       $t0, C
            ldc1     $f8, 0($t0)  # $f8 <- valor de C
            
            jal      calculaDelta
            
            la       $t0, Delta
            sdc1     $f0, 0($t0)  # guarda o valor de Delta na memoria
            
            li       $t0, 0
            mtc1     $t0, $f8
            cvt.d.w  $f8, $f8
            c.lt.d   $f0, $f8
            bc1t     deltaNegativo
            
            # calculando x'
            la       $t0, A
            ldc1     $f4, 0($t0)  # $f4 <- valor de A
            add.d    $f4, $f4, $f4  # $f4 <- 2*A
            
            la       $t0, B
            ldc1     $f6, 0($t0)  # $f6 <- valor de B
            sub.d    $f8, $f8, $f6  # $f8 <- -B
            
            sqrt.d   $f14, $f0  # $f14 <- sqrt(Delta)
            add.d    $f16, $f8, $f14  # $f16 <- -B + sqrt(Delta)
            div.d    $f18, $f16, $f4  # $f18 <- (-B + sqrt(Delta)) / 2*A
            la       $t0, raiz1
            sdc1     $f18, 0($t0)
            
            # calculando x''
            sub.d    $f16, $f8, $f14  # $f16 <- -B - sqrt(Delta)
            div.d    $f18, $f16, $f4  # $f18 <- (-B + sqrt(Delta)) / 2*A
            la       $t0, raiz2
            sdc1     $f18, 0($t0)
            j        imprimeResultados
            
calculaDelta:  # b*b - 4*a*c       
# corpo do procedimento
            # f4, f6 e f8 tenho os valores de A, B e C respectivamente
            li       $t0, 4
            mtc1     $t0, $f18  # move o valor 4 para o coprocessador
            cvt.d.w  $f18, $f18  # converte o valor para precisao dupla
            mul.d    $f14, $f6, $f6  # $f14 <- b*b
            mul.d    $f16, $f4, $f8  # $f16 <- a*c
            mul.d    $f16, $f16, $f18  # $f16 <- 4*a*c
            sub.d    $f0, $f14, $f16  # $f0 <- b*b - 4*a*c
# epilogo
            jr       $ra
            
deltaNegativo:
            la       $a0, msgDeltaNegativo
            li       $v0, 4
            syscall
            j        encerraPrograma

imprimeResultados:
            la       $a0, separacao
            li       $v0, 4
            syscall
            
            la       $a0, msgResultado
            li       $v0, 4
            syscall
            
            la       $a0, quebraLinha
            li       $v0, 4
            syscall
            
            la       $a0, msgResult1
            li       $v0, 4
            syscall
            
            la       $t0, raiz1
            ldc1     $f12, 0($t0)
            li       $v0, 3
            syscall
            
            la       $a0, quebraLinha
            li       $v0, 4
            syscall
            
            la       $a0, msgResult2
            li       $v0, 4
            syscall
            
            la       $t0, raiz2
            ldc1     $f12, 0($t0)
            li       $v0, 3
            syscall

encerraPrograma:
            li       $a0, 0
            li       $v0, 17
            syscall
            
            
.data
A:                 .space 8
B:                 .space 8
C:                 .space 8
Delta:             .space 8
raiz1:             .space 8
raiz2:             .space 8
msgInicial:        .asciiz " Programa que calcula as raizes de uma\n funcao quadratica de segundo grau!\n"
msgInforme:        .asciiz " Informe os valores de A, B e C!\n"
msgA:              .asciiz " A = "
msgB:              .asciiz " B = "
msgC:              .asciiz " C = "
msgDeltaNegativo:  .asciiz " Delta negativo!\n Raizes imaginarias!!!\n O programa serah encerrado!\n"
msgResult1:        .asciiz " x' = "
msgResult2:        .asciiz " x'' = "
msgResultado:      .asciiz " Resultados:"
separacao:         .asciiz "------------------------------------------\n"
quebraLinha:       .asciiz "\n"