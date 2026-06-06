.global abs_value
.global power2
.global hailstone_length

.text

abs_value:
	mov %rdi, %rax	# cp argument x into return register
	cmp $0, %rax 	# compare x with 0
	jge abs_done	# if x >= 0, do not change into
	neg %rax		# if x < 0, negate it
abs_done:
	ret

power2:
	push %rbx		# save register
	push %r12
	push %r13

	mov %rdi, %r12	# r12 = n
	mov $0, %r13	# r13 = loop counter i
	mov $1, %rbx	# rbx = current value (power of 2)

power2_loop:
	cmp %r12, %r13	# compare i with n
	ja power2_done	# if i > n, stop

	mov %rbx, %rdi	# argument for print_uint64
	call print_uint64

	add %rbx, %rbx 	# current *= 2
	add $1, %r13 	# i++
	jmp power2_loop	#repeat

power2_done:
	pop %r13	# restore saved register
	pop %r12
	pop %rbx
	ret

hailstone_length:
	mov $0, %rax 	# length = 0

hail_loop:
	cmp $1, %rdi	# check if n == 1
	je hail_done 	# if n == 1, return length

	add $1, %rax 	# length++

	mov %rdi, %rcx	# cp n into rcx for check
	and $1, %rcx	# check lowest of n
	jz hail_even 	# if n is even (lowest == 0), jump to `hail_even`

hail_odd:		# if odd, cont.
	imul $3, %rdi	# n = 3 * n 
	add $1, %rdi	# n = 3 * n + 1
	jmp hail_loop	# cont. loop

hail_even:
	shr $1, %rdi	# n = n / 2
	jmp hail_loop	# cont. loop

hail_done:
	ret

.section .note.GNU-stack,"",@progbits
