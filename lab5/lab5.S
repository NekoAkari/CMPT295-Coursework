	.section .note.GNU-stack, ""
	.text
	.globl fibonacci

fibonacci:
	# Check (n <= 1), return n;
	cmp $1, %rdi
	jbe .return

	# save n
	push %rdi

	# fibonacci(n - 1);
	sub $1, %rdi
	call fibonacci

	# Save result
	push %rax

	# Restore n, then calculate fib(n - 2)
	mov 8(%rsp), %rdi
	sub $2, %rdi

	# alignment and call
	sub $8, %rsp
	call fibonacci
	add $8, %rsp

	# Add fib(n - 1)
	pop %rsi
	add %rsi, %rax

	pop %rdi
	ret		# == pop %rip (return %rax)

.return:
	mov %rdi, %rax
	ret

	.globl polynomial1
polynomial1:
	# a * x * x * x
	mov %rsi, %rax
	imul %rdi, %rax
	imul %rdi, %rax
	imul %rdi, %rax

	# b*x*x
	imul %rdi, %rdx
	imul %rdi, %rdx
	add %rdx, %rax

	# c*x
	imul %rdi, %rcx
	add %rcx, %rax

	# +d
	add %r8, %rax
	ret

	.globl polynomial2
polynomial2:
	# a*b + b
	mov %rsi, %rax
	imul %rdi, %rax
	add %rdx, %rax

	# x*(a*x + b) + c
	imul %rdi, %rax
	add %rcx, %rax

	# x*(x*(a*x + b) + c) + d
	imul %rdi, %rax
	add %r8, %rax
	ret

	.globl is_odd1
is_odd1:
	mov %rdi, %rax
	cqto			#fixed by chatGPT
	mov $2, %rsi		# divider = 2
	idiv %rsi

	mov %rdx, %rax

	and $1, %rax
	ret

	.globl is_odd2
is_odd2:
	mov %rdi, %rax
	and $1, %rax
	ret

	.globl mul1
mul1:
	mov %rdi, %rax		# %rax = n
	mov $65537, %rsi	# multiplier = 65537
	mul %rsi		# %rdx:%rax = %rax * %rsi
	ret

	.globl mul2
mul2:
	mov %rdi, %rax 		# %rax = n;
	shl $16, %rax		# %rax = n * 2^16
	add %rdi, %rax		# %rax = n * 2^16 + n
	ret
