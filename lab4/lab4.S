	.section .note.GNU-stack, ""
	.text
	.globl is_prime
is_prime:
	mov $2, %r8

prime_loop:
	cmp %rdi, %r8		# if i >= n, return 1
	jae prime_yes

	mov $0, %rdx		# rdx:rax = n
	mov %rdi, %rax
	div %r8			# n / 1, remainder goto rdx

	cmp $0, %rdx
	je prime_no		#if n % i == 0, return 0;

	inc %r8
	jmp prime_loop

prime_yes:
	mov $1, %rax
	ret

prime_no:
	mov $0, %rax
	ret

	.globl largest_power_unsigned
largest_power_unsigned:
	cmp $0, %rdi
	je lpu_zero
	cmp $1, %rdi
	je lpu_one

	mov $1, %rax		# p = 1

lpu_loop:
	mov %rax, %r8		# save prev. p
	mul %rdi		# unsigned: rdx:rax = rax * n;
	jc lpu_overflow		# if carry flag, overflow
	jmp lpu_loop

lpu_overflow:
	mov %r8, %rax		# return perv. p
	ret

lpu_zero:
	mov $0, %rax
	ret

lpu_one:
	mov $1, %rax
	ret

	.globl overflowing_subtract
overflowing_subtract:
	mov %rdi, %rax		# rax = a
	sub %rsi, %rax		# rax = a - b
	jo sub_overflow		# signed overflow
	ret

sub_overflow:
	mov $0, %rax
	ret

	.globl dumb
dumb:
	cmp $0, %rdi
	je dumb_a_zero

	cmp $0, %rsi
	je dumb_b_zero

	# save origin a and b on stack before recursive call
	# subtract 24, stack aligned before call
	sub $24, %rsp
	mov %rdi, 0(%rsp)	# save a
	mov %rsi, 8(%rsp)	# save b

	dec %rdi		# a - 1
	dec %rsi		# b - 1
	call dumb		# rax = dumb(a - 1, b - 1);

	mov 0(%rsp), %r8	# restore a
	mov 8(%rsp), %r9	# restore b
	add $24, %rsp

	lea (%rax,%r8,2), %rax	# rax = recursice_result + 2 * a;
	add %r9, %rax		# rax += b;
	ret

dumb_a_zero:
	lea 1(%rsi), %rax	# return b + 1;
	ret

dumb_b_zero:
	mov %rdi, %rax		# return a;
	ret
