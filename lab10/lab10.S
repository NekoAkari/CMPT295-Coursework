	.section .note.GUN-stack, ""
	.text

	.globl dot_double

dot_double:
	xorpd %xmm0, %xmm0		# total = 0.0
	xorq %rcx, %rcx			# i = 0

dot_double_loop:
	cmpq %rdx, %rcx 		# compare i with length
	jae dot_double_done		# if 1 >= length, done

	movsd (%rdi, %rcx, 8), %xmm1	# xmm1 = arr1[i]
	mulsd (%rsi, %rcx, 8), %xmm1	# xmm1 = arr1[i] * arr2[i]
	addsd %xmm1, %xmm0		# total += xmm1

	incq %rcx 			# i++
	jmp dot_double_loop

dot_double_done:
	ret				# return total in xmm0

	.globl map_poly_double
map_poly_double:
	xorq %rcx, %rcx			# i = 0

.Lmap_poly_double_loop:
	cmpq %rdx, %rcx			# compare i with length
	jae .Lmap_poly_double_done	# if i >= length, done

	movsd (%rdi, %rcx, 8), %xmm4	# xmm4 = x = input[i]

	movapd %xmm0, %xmm5		# xmm5 = a
	mulsd %xmm4, %xmm5		# xmm5 = a*x
	addsd %xmm1, %xmm5		# xmm5 = a*x + b

	mulsd %xmm4, %xmm5		# xmm5 = (a*x + b)*x
	addsd %xmm2, %xmm5		# xmm5 = (a*x + b)*x + c

	mulsd %xmm4, %xmm5		# xmm5 = ((a*x + b)*x + c)*x
	addsd %xmm3, %xmm5		# xmm5 = ((a*x + b)*x + c)*x + d

	movsd %xmm5, (%rsi, %rcx, 8)	# output[i] = result

	incq %rcx			# i++
	jmp .Lmap_poly_double_loop

.Lmap_poly_double_done:
	ret

	.globl dot_single
dot_single:
	xorps %xmm0, %xmm0		# total = 0.0f
	xorq %rcx, %rcx			# i = 0

.Ldot_single_loop:
	cmpq %rdx, %rcx			# compare i with length
	jae .Ldot_single_done

	movss (%rdi, %rcx, 4), %xmm1	# xmm1 = arr1[i]

	mulss (%rsi, %rcx, 4), %xmm1	# xmm1 = arr1[i] * arr2[i]

	addss %xmm1, %xmm0 		# total += xmm1

	incq %rcx			# i++
	jmp .Ldot_single_loop

.Ldot_single_done:
	ret

	.globl map_poly_single
map_poly_single:
	xorq %rcx, %rcx			# i = 0

.Lmap_poly_single_loop:
	cmpq %rdx, %rcx			# compare i and length
	jae  .Lmap_poly_single_done	# if i >= length, finish

	movss (%rdi, %rcx, 4), %xmm4	# xmm4 = x = input[i]

	movaps %xmm0, %xmm5		# xmm5 = a
	mulss %xmm4, %xmm5		# xmm5 = a*x
	addss %xmm1, %xmm5		# xmm5 = a*x + b

	mulss %xmm4, %xmm5		# xmm5 = (a*x + b)*x
	addss %xmm2, %xmm5		# xmm5 = (a*x + b)*x + c

	mulss %xmm4, %xmm5		# xmm5 = ((a*x + b)*x + c)*x
	addss %xmm3, %xmm5		# xmm5 = ((a*x + b)*x + c)*x + d

	movss %xmm5, (%rsi, %rcx, 4)	# output[i] = result

	incq %rcx			# i++
	jmp  .Lmap_poly_single_loop

.Lmap_poly_single_done:
	ret

	.globl sin_x87
sin_x87:
	mov $0, %rcx

s87_loop:
	cmp %rdx, %rcx
	jae s87_ret
	fldl (%rdi, %rcx, 8)
	fsin
	fstpl (%rsi, %rcx, 8)
	inc %rcx
	jmp s87_loop

s87_ret:
	ret

	.section .note.GNU-stack,"",@progbits
