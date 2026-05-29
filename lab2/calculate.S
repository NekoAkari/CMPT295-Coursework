	.section .note.GNU-stack,""
	.global calculate
	.text

calculate:
	# calculate(x)
	# x is originally in `%rdi`
	#
	# %rbx = x 
	# %r12 = a = x + 3
	# %r13 = b
	# %r14 = c
	# %r15 = d
	# %r10 = temporary copy of a

	# Save call-preserved registers.
	push %rbx
	push %r12
	push %r13
	push %r14
	push %r15

	# Save original x.
	mov %rdi, %rbx

	# a = x + 3.
	mov %rbx, %r12
	add $3, %r12

	# Use a non-preserved registers before calling f.
	# Since f destorys non-preserved registers, save `%r10` on the stack.
	mov %r12, %r10
	sub $16, %rsp
	mov %r10, (%rsp)

	# b = f(x, a)
	mov %rbx, %rdi
	mov %r12, %rsi
	call f

	# Restore the non-preserved value and use it after the call.
	mov (%rsp), %r10
	add $16, %rsp
	mov %r10, %r12

	# save b.
	mov %rax, %r13

	# c = f(b, x)
	mov %r13, %rdi
	mov %rbx, %rsi
	call f
	mov %rax, %r14

	# d = f(x, c)
	mov %rbx, %rdi
	mov %r14, %rsi
	call f
	mov %rax, %r15

	# return a + b + c + d
	mov %r12, %rax
	add %r13, %rax
	add %r14, %rax
	add %r15, %rax

	# Restore call-preserved registers.
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	pop %rbx
	
	ret


