################################################################################
#
#  Questao 2 do trabalho de Organizacao de Computadores (ELC1011)
#  Objetivo: Construir um programa que seja capaz de fazer a multiplicacao
#  de dois numeros, utilizando o algoritmo de Booth.
#
################################################################################
#
#
#            PILHA
#    multiplicando      0($sp)
#    multiplicador      4($sp)
#    produto HIGH       8($sp)
#    produto LOW       12($sp)
#    BIT AUXILIAR      16($sp)
#    cont de iteracoes 20($sp)
#
################################################################################
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                              #
#
.text
main:
# prologo
            addi  $sp, $sp, -24                  # ajusta a pilha pra receber 6 elementos
# corpo do procedimento
            # impressao do cabecalho do programa
            la    $a0, msgInicial
            li    $v0, 4
            syscall
            
            la    $a0, separacao
            li    $v0, 4
            syscall
            
            # pede para o usuario informar os valores do multiplicando
            # e do multplicador com as chamadas do sistema
            
            la    $a0, msgIteracao1
            li    $v0, 4
            syscall
            
            li    $v0, 5
            syscall
            move  $t0, $v0                       # pega o valor lido do usuario e coloca em $t0
            
            la    $a0, msgIteracao2
            li    $v0, 4
            syscall
            
            li    $v0, 5
            syscall
            move  $t1, $v0                       # pega o valor lido do usuario e coloca em $t1
            
            sw    $t0, 0($sp)                    # salva multiplicando na pilha
            sw    $t1, 4($sp)                    # salva multiplicador na pilha
            sw    $zero, 8($sp)                  # salva produto HIGH na pilha
            sw    $t1, 12($sp)                   # salva produto LOW na pilha
            # contador de iteracoes = numero de bits do numero = N
            li    $t1, 32                        # cont comeca em 32
            sw    $t1, 20($sp)                   # guarda o valor de cont na pilha
            # BIT AUXILIAR
            sw    $zero, 16($sp)                 # guarda 0 no BA - valor inicial
loop:
            lw    $t0, 20($sp)                   # $t0 <- valor de cont
            beq   $t0, 0, imprimeResultados
            subi  $t0, $t0, 1                    # cont <- cont - 1
            sw    $t0, 20($sp)                   # guarda o valor de cont atualizado na pilha
            lw    $t0, 12($sp)                   # pega valor do PL da pilha
            lw    $t1, 16($sp)                   # pega valor do BA da pilha
            andi  $t2, $t0, 0x00000001           # $t1 <- LSB do produto LOW
            beq   $t1, $t2, naoFazNada           # se LSB == BA, apenas desloca os numeros, sem operacao
            beq   $t1, 0, subtrai                # se LSB != BA && LSB == 0, faz a operacao de subtracao
soma:
            lw    $t0, 8($sp)                    # $t0 <- valor do produto HIGH
            lw    $t1, 0($sp)                    # $t1 <- valor do multiplicando
            addu  $t1, $t0, $t1                  # $t1 <- produto HIGH + multiplicando
            andi  $t2, $t1, 0x80000000           # pega MSB de PH para replicar
            andi  $t3, $t1, 0x00000001           # pega LSB de PH para arrumar PL
            beq   $t2, 0x80000000, replicaMSBPH_sum
            srl   $t1, $t1, 1                    # se MSB != 1, apenas desloca replicando o 0
returnReplicaSoma:
            sw    $t1, 8($sp)                    # guarda o valor de PH atualizado
            lw    $t1, 12($sp)                   # $t1 <- valor de PL
            andi  $t2, $t1, 0x00000001           # LSB de PL para arrumar o valor de BA
            sw    $t2, 16($sp)                   # guarda o valor de BA atualizado na pilha
            srl   $t1, $t1, 1                    # desloca PL para direita
            beq   $t3, 0x00000001, arrumaMSBPL   # se LSB de PH == 1, ajusta o MSB de PL
            sw    $t1, 12($sp)                   # guarda o valor atualizado de PL
            j     loop

naoFazNada:
            lw    $t1, 8($sp)                    # $t0 <- valor do produto HIGH
            andi  $t2, $t1, 0x80000000           # pega MSB de PH para replicar
            andi  $t3, $t1, 0x00000001           # pega LSB de PH para arrumar PL
            beq   $t2, 0x80000000, replicaMSBPH_NFN
            srl   $t1, $t1, 1                    # se MSB != 1, apenas desloca replicando o 0
returnReplicaNFN:
            sw    $t1, 8($sp)                    # guarda o valor de PH atualizado
            lw    $t1, 12($sp)                   # $t1 <- valor de PL
            andi  $t2, $t1, 0x00000001           # LSB de PL para arrumar o valor de BA
            sw    $t2, 16($sp)                   # guarda o valor de BA atualizado na pilha
            srl   $t1, $t1, 1                    # desloca PL para direita
            beq   $t3, 0x00000001, arrumaMSBPL   # se LSB de PH == 1, ajusta o MSB de PL
            sw    $t1, 12($sp)                   # guarda o valor atualizado de PL
            j     loop
            
subtrai:
            lw    $t0, 8($sp)                    # $t0 <- valor do produto HIGH
            lw    $t1, 0($sp)                    # $t1 <- valor do multiplicando
            sub   $t1, $zero, $t1                # $t1 <- multiplicando complementado
            addu  $t1, $t0, $t1                  # $t1 <- produto HIGH + multiplicando complementado
            andi  $t2, $t1, 0x80000000           # pega MSB de PH para replicar
            andi  $t3, $t1, 0x00000001           # pega LSB de PH para arrumar PL
            beq   $t2, 0x80000000, replicaMSBPH_sub
            srl   $t1, $t1, 1                    # se MSB != 1, apenas desloca replicando o 0
returnReplicaSubtrai:
            sw    $t1, 8($sp)                    # guarda o valor de PH atualizado
            lw    $t1, 12($sp)                   # $t1 <- valor de PL
            andi  $t2, $t1, 0x00000001           # LSB de PL para arrumar o valor de BA
            sw    $t2, 16($sp)                   # guarda o valor de BA atualizado na pilha
            srl   $t1, $t1, 1                    # desloca PL para direita
            beq   $t3, 0x00000001, arrumaMSBPL   # se LSB de PH == 1, ajusta o MSB de PL
            sw    $t1, 12($sp)                   # guarda o valor atualizado de PL
            j     loop

replicaMSBPH_sum:
            srl   $t1, $t1, 1                    # deslocamento logico pra direita do PH
            addi  $t1, $t1, 0x80000000           # adiciona 1 no MSB de PL
            sw    $t1, 8($sp)                    # guarda o valor do PH atualizado
            j     returnReplicaSoma
replicaMSBPH_NFN:
            srl   $t1, $t1, 1                    # deslocamento logico pra direita do PH
            addi  $t1, $t1, 0x80000000           # adiciona 1 no MSB de PL
            sw    $t1, 8($sp)                    # guarda o valor do PH atualizado
            j     returnReplicaNFN
replicaMSBPH_sub:
            srl   $t1, $t1, 1                    # deslocamento logico pra direita do PH
            addi  $t1, $t1, 0x80000000           # adiciona 1 no MSB de PL
            sw    $t1, 8($sp)                    # guarda o valor do PH atualizado
            j     returnReplicaSubtrai
arrumaMSBPL:
            addi  $t1, $t1, 0x80000000           # adiciona 1 no MSB de PL
            sw    $t1, 12($sp)                   # guarda o valor atualizado de PL
            j     loop
imprimeResultados:
            la    $a0, separacao
            li    $v0, 4
            syscall
            
            la    $a0, msgResultado
            li    $v0, 4
            syscall
            
            la    $a0, msgPH
            li    $v0, 4
            syscall
            
            lw    $a0, 8($sp)
            li    $v0, 34
            syscall
            
            la    $a0, quebraLinha
            li    $v0, 4
            syscall

            la    $a0, msgPL
            li    $v0, 4
            syscall
            
            lw    $a0, 12($sp)
            li    $v0, 34
            syscall

# epilogo
            addi  $sp, $sp, 24                   # restaura a pilha
            li    $a0, 0
            li    $v0, 17
            syscall
            
.data
msgInicial:     .asciiz " MULTIPLICADOR DE BOOTH\n"
msgIteracao1:   .asciiz " Digite o multiplicador: "
msgIteracao2:   .asciiz " Digite o multiplicando: "
msgResultado:   .asciiz " Resultado da multiplicacao:\n"
msgPH:          .asciiz " Produto HIGH = "
msgPL:          .asciiz " Produto LOW = "
quebraLinha:    .asciiz "\n"
separacao:      .asciiz "----------------------------\n"