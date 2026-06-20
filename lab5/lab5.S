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
