.text

b start

@Vetor que possui os valores do display de 7 seg: 0 - 1 - 2 - 3
seg:
.word 0xed
.word 0x60
.word 0xce
.word 0xea

@Vetor com a senha do modo memorização
memo:
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0

@Vetor com a senha do modo acesso
acesso:
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0

@Mensagens que aparecerão no display
@m1: 	.asciz "----------------------------------------"
m1: 	.asciz "Aperte left para entrar em memorizacao"
m2: 	.asciz "Digite a nova senha para memorizacao:"
m3: 	.asciz "Senha memorizada"
m4: 	.asciz "Digite a senha cadastrada para acessar"
m5: 	.asciz "Acesso autorizado"
m6: 	.asciz "Senha incorreta"
m7: 	.asciz "Numero maximo de tentativas atingido"
m8: 	.asciz "Bloqueado aguardando servico"

start:					@Comeco do programa
	mov r0, #0			@Coloca r0 igual a 0 para limpar os plugins
	swi 0x201			@Apaga os leds
	swi 0x200			@Apaga o display
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com as variaveis certas para imprimir na tela
	mov r1, #0
	ldr r2, =m1
	
	swi 0x204			@Imprime a m1 na tela
	mov r3, #1			@Coloca r3 igual a 1 para o loop de comparacao
	b loopMemorizacao

loopMemorizacao:		@Loop para o usuario pressionar left
	swi 0x202			@Guarda em r0 qual botao foi pressionado
	cmp r0, r3			@Checa se r0 igual a 1, ou seja, botao pressionado foi esquerda
	beq etapa1 			@Caso sim sai do loop
	bne	loopMemorizacao @Caso não continua loopando
	
etapa1:					@Branch auxiliar para limpar a tela e arrumar as variaveis
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m2
	swi 0x204			@Imprime a m2 na tela
	
						@Coloca os registradores com os valores certos para imprimir na tela
	ldr r4, =memo		@r4 controla o vetor que memoriza a senha
	mov r5, #0			@r5 controla quantos digitos foram colocados pelo usuario
	mov r6, #'*			@r6 possui o caractere asterisco que sera impresso
	mov r7, #' 			@r7 possui o caractere espaco que sera impresso
	swi 0x203			@Zera a variavel que recebe o teclado azul
	b memAzul

memAzul:				@Branch responsavel por receber e gravar a senha do usuario
	swi 0x203			@Recebe o que o usuario digitou no teclado azul e guarda em r0
	
	cmp r0, #0			@Se o usuario nao apertou nada
	beq memBotao		@Pula para o proximo branch
	
	cmp r5, #8			@Se tiver 8 elementos no vetor
	beq memBotao		@Pula para o proximo branch
	
	add r5, r5, #1		@Incrementa r5
	str r0, [r4]		@Grava o que o usuario digitou em r4
	add r4, r4, #4		@Incrementa r4 para a prox posicao
						@Coloca os registradores com os valores certos para imprimir na tela 
	mov r1, #1			@Segunda linha
	mov r0, r5			@"r5" coluna
	mov r2, r6			@Guarda o char '*' no r2
	swi 0x207			@Imprime um '*' na tela
	b memBotao			@Pula para o proximo branch

memBotao:				@Branch responsavel por receber os botoes que o usuario pressionou
	swi 0x202			@Recebe qual botao o usuario pressionou
	
	cmp r0, #0			@Se o usuario apertou nada
	beq memAzul			@Pula para o branch anterior
	cmp r5, #0			@Se o vetor estiver com 0 elementos
	beq memAzul			@Pula para o branch de anterior
	
	cmp r0, #1			@Se o usuario apertou left
	beq memPassa		@Pula para o branch final da etapa
						@Se o usuario apertou right
						@Coloca os registradores com os valores certos para imprimir na tela 
	mov r1, #1			@Segunda linha
	mov r0, r5			@"r5" coluna
	mov r2, r7			@Guarda o char ' ' no r2
	swi 0x207			@Imprime um ' ' na tela, apagando o '*'
	sub r4, r4, #4		@Volta o r4 para a posicao anterior
	sub r5, r5, #1		@Decrementa r5
	b memAzul			@Pula para o branch anterior				

memPassa:				@Branch para a proxima etapa
	cmp r5, #8			@Verifica se foram fornecidos 8 digitos
	beq etapa2			@Pula para a proxima etapa
	b memAzul			@Retorna para o branch anterior

etapa2:					@Branch auxiliar para limpar a tela e arrumar as variaveis
	swi 0x206			@Limpa a tela
						@Coloca os registradores com os valores certos para imprimir na tela 
	mov r0, #0
	mov r1, #0
	ldr r2, =m3			
	swi 0x204			@Imprime a m3
	mov r0, #1			@Atribui 1 ao r0 para acender o led
	swi 0x201			@Acende o led da esquerda
						@Atribui 5000 ao r3, para fazer a espera de 5 segundos
	mov r3, #0
	add r3, r3, #1000
	add r3, r3, #1000
	add r3, r3, #1000
	add r3, r3, #1000
	add r3, r3, #1000
	b espera
	
espera:
	swi 0x6d			
	mov r1, r0 			@Atribui a r1 o tempo inicial
	b esperaLoop		@Pula para o loop de epera
esperaLoop:
	swi 0x6d			@Atribui o tempo atual para r0
	subs r0, r0, r1 	@Conta o tempo passado
	rsblt r0, r0, #0 	@Conserta valor negativo
	cmp r0, r3			@Compara com o valor de r3
	blt esperaLoop		@Caso seja menor continua o loop
	b etapa3			@Pula para a proxima etapa
	
etapa3:
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m4
	swi 0x204			@Imprime a m4 na tela
	
						@Coloca os registradores com os valores certos para imprimir na tela
	ldr r3, =acesso		@r3 controla o vetor que memoriza a senha de acesso
	mov r5, #0			@r5 controla quantos digitos foram colocados pelo usuario
	
	ldr r8, =seg		@r8 controla os valores a serem impressos no vetor de 7 segmentos
	ldrb r0, [r8], #4	@Atribui o primeiro valor ao r0 e incrementa o r8
	swi 0x200			@Acende o valor 0 no display de 7 segmentos
	b acessoAzul

acessoAzul:				@Branch responsavel por receber e gravar a senha de acesso do usuario
	swi 0x203			@Recebe o que o usuario digitou no teclado azul e guarda em r0
	
	cmp r0, #0			@Se o usuario nao apertou nada
	beq acessoBotao		@Pula para o proximo branch
	
	cmp r5, #8			@Se tiver 8 elementos no vetor
	beq acessoBotao		@Pula para o proximo branch
	
	add r5, r5, #1		@Incrementa r5
	str r0, [r3]		@Grava o que o usuario digitou em r3
	add r3, r3, #4		@Incrementa r3 para a prox posicao
						@Coloca os registradores com os valores certos para imprimir na tela 
	mov r1, #1			@Segunda linha
	mov r0, r5			@"r5" coluna
	mov r2, r6			@Guarda o char '*' no r2
	swi 0x207			@Imprime um '*' na tela
	b acessoBotao		@Pula para o proximo branch

acessoBotao:			@Branch responsavel por receber os botoes que o usuario pressionou
	swi 0x202			@Recebe qual botao o usuario pressionou
	
	cmp r0, #0			@Se o usuario apertou nada
	beq acessoAzul		@Pula para o branch anterior
	cmp r5, #0			@Se o vetor estiver com 0 elementos
	beq acessoAzul		@Pula para o branch de anterior
	
	cmp r0, #1			@Se o usuario apertou left
	beq acessoPassa		@Pula para o branch final da etapa
						@Se o usuario apertou right
						@Coloca os registradores com os valores certos para imprimir na tela 
	mov r1, #1			@Segunda linha
	mov r0, r5			@"r5" coluna
	mov r2, r7			@Guarda o char ' ' no r2
	swi 0x207			@Imprime um ' ' na tela, apagando o '*'
	sub r3, r3, #4		@Volta o r3 para a posicao anterior
	sub r5, r5, #1		@Decrementa r5
	b acessoAzul		@Pula para o branch anterior				

acessoPassa: 			@Branch para a proxima etapa
	cmp r5, #8			@Verifica se foram fornecidos 8 digitos
	beq compara			@Pula para a proxima etapa
	b acessoAzul		@Retorna para o branch anterior
	
compara:				@Branch que prepara os registradores para o loop de comparacao
	mov r9, #8			@r9 vai controlar o loop de comparacao
	ldr r0, =memo		@r0 controla o vetor memorizado
	ldr r1, =acesso		@r1 controla o vetor de acesso
	b comparaLoop		@Pula para o loop de comparacao
	
comparaLoop:			@Branch que faz a comparacao dos dois vetores
	ldrb r2, [r0], #4	@Guarda em r2 um valor e incrementa r0
	ldrb r3, [r1], #4	@Guarda em r3 um valor e incrementa r1
	
	cmp r2, r3			@Compara r2 e r3
	bne senhaIncorreta	@Caso diferentes pula para o branch de erro
	
						@r2 e r3 iguais
	sub r9, r9, #1		@Decrementa r9
	cmp r9, #0			@Compara o numero de valores restantes no vetor
	beq senhaCorreta	@Caso igual a senha esta correta
	b comparaLoop		@Volta para o loop

senhaIncorreta:			@Branch caso de senha errada
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m6
	swi 0x204			@Imprime a m6 na tela
	
	ldrb r0, [r8], #4	@Atribui o proximo valor ao r0 e incrementa o r8
	swi 0x200			@Acende o valor 0 no display de 7 segmentos
	
	cmp r0, #0xea		@Compara o r0 com o valor correspondente a 3 no display 7 segmentos
	beq senhaErro		@Tres tentativas acabaram vai para o branch de erro
	
	mov r5, #0			@Reseta o r5 para a proxima tentativa
	ldr r3, =acesso		@Reseta o r3 para a proxima tentativa 
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m4
	swi 0x204			@Imprime a m4 na tela
	b acessoAzul		@Volta para a proxima tentativa

senhaCorreta:			@Branch caso de senha correta
	mov r0, #0			@Atribui 0 ao r0 para apagar o led
	swi 0x201			@Apaga o led da esquerda
	
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m5
	swi 0x204			@Imprime a m5 na tela
	b start				@Encerra o programa

senhaErro:				@Branch caso atngir numero maximo de tentativas
	mov r0, #3			@Atribui 0 ao r0 para acender ambos os leds
	swi 0x201			@Acende ambos os leds
	
	swi 0x206			@Limpa a tela
	mov r0, #0			@Coloca os registradores com os valores certos para imprimir na tela
	mov r1, #0
	ldr r2, =m7
	swi 0x204			@Imprime a m7 na tela

	mov r1, #1			@Coloca os registradores com os valores certos para imprimir na tela
	ldr r2, =m8
	swi 0x204			@Imprime a m8 na tela
	b end				@Encerra o programa
	
end: 					@Loop de encerramento do programa
	b end