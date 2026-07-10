	.section .note.GNU-stack, ""
	.text

    .globl hailstone_length
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


	.globl hailstone_length_cmov
hailstone_length_cmov:
	mov $0, %rax		# length = 0

cmov_loop:
	cmp $1, %rdi		# check if n == 1
	je cmov_done

	add $1, %rax		# length++

	lea 1(%rdi,%rdi,2), %rcx	# rcx = 3*n + 1
	mov %rdi, %rdx			# rdx = n
	shr $1, %rdx			# rdx = n / 2

	test $1, %rdi			# check if n is odd
	cmovnz %rcx, %rdx		# if odd, use 3*n + 1

	mov %rdx, %rdi			# n = selected result
	jmp cmov_loop

cmov_done:
	ret