	.section .note.GNU-stack, ""
	.text

	.globl dot_double
dot_double:
	xorpd %xmm0, %xmm0		# total = 0.0
	xorq %rcx, %rcx			# i = 0

dot_double_loop:
	cmpq %rdx, %rcx 		# compare i with length
	jae dot_double_done		# if i >= length, done

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

	.globl dot_double_vec
dot_double_vec:
	vxorpd %ymm0, %ymm0, %ymm0		# four partial totals = 0
	xorq %rcx, %rcx			# i = 0

.Ldot_double_vec_loop:
	cmpq %rdx, %rcx 		# compare i with length
	jae .Ldot_double_vec_reduce		# if i >= length, finish

	vmovupd (%rdi, %rcx, 8), %ymm1 	# load 4 double from arr1
	vmulpd (%rsi, %rcx, 8), %ymm1, %ymm1
	vaddpd %ymm1, %ymm0, %ymm0		# add products to partial totals

	addq $4, %rcx			# i += 4
	jmp .Ldot_double_vec_loop

.Ldot_double_vec_reduce:
	vextractf128 $1, %ymm0, %xmm1	# get upper two totals
	vaddpd %xmm1, %xmm0, %xmm0		# combine upper and lower halves
	vhaddpd %xmm0, %xmm0, %xmm0		# add the final two totals

	vzeroupper
	ret

	.globl dot_single_vec
dot_single_vec:
	vxorps %ymm0, %ymm0, %ymm0		# eight partial totals = 0
	xorq %rcx, %rcx			# i = 0

.Ldot_single_vec_loop:
	cmpq %rdx, %rcx
	jae .Ldot_single_vec_reduce		# if i >= length, reduce totals

	vmovups (%rdi, %rcx, 4), %ymm1	# load 8 floats from arr1
	vmulps (%rsi, %rcx, 4), %ymm1, %ymm1
	vaddps %ymm1, %ymm0, %ymm0		# update eight partial total

	addq $8, %rcx			# i += 8
	jmp .Ldot_single_vec_loop

.Ldot_single_vec_reduce:
	vextractf128 $1, %ymm0, %xmm1	# extract upper four totals
	vaddps %xmm1, %xmm0, %xmm0		# combine upper and lower halves
	vhaddps %xmm0, %xmm0, %xmm0		# four totals → two totals
	vhaddps %xmm0, %xmm0, %xmm0		# two totals → final total

	vzeroupper
	ret
	
	.globl map_poly_double_vec
map_poly_double_vec:
	# Broadcast a, b, c, d into fore-element vectors
	vbroadcastsd %xmm0, %ymm4	# ymm4= {a, a, a, a}
	vbroadcastsd %xmm1, %ymm5	# ymm5= {b, b, b, b}
	vbroadcastsd %xmm2, %ymm6	# ymm6= {c, c, c, c}
	vbroadcastsd %xmm3, %ymm7	# ymm7= {d, d, d, d}
	
	xorq %rcx, %rcx			# i = 0
	

.Lmap_poly_double_vec_loop:
	cmpq %rdx, %rcx
	jae .Lmap_poly_double_vec_done

	vmovupd (%rdi, %rcx, 8), %ymm8	# load 4 x values

	# result = ((a*x + b)*x + c)*x + d
	vmulpd %ymm8, %ymm4, %ymm9	# result = a*x
	vaddpd %ymm5, %ymm9, %ymm9	# result = a*x + b

	vmulpd %ymm8, %ymm9, %ymm9	# result = (a*x + b)*x
	vaddpd %ymm6, %ymm9, %ymm9	# result = (a*x + b)*x + c

	vmulpd %ymm8, %ymm9, %ymm9
	vaddpd %ymm7, %ymm9, %ymm9	# result = ((a*x+b)*x+c)*x+d

	vmovupd %ymm9, (%rsi, %rcx, 8)	# store 4 results

	addq $4, %rcx			# i += 4
	jmp .Lmap_poly_double_vec_loop

.Lmap_poly_double_vec_done:
	vzeroupper
	ret

	.globl map_poly_single_vec
map_poly_single_vec:
	# Broadcast a, b, c, d into eight-element vectors
	vbroadcastss %xmm0, %ymm4	# ymm4 = {a, a, a, a, a, a, a, a}
	vbroadcastss %xmm1, %ymm5	# ymm5 = {b, b, b, b, b, b, b, b}
	vbroadcastss %xmm2, %ymm6	# ymm6 = {c, c, c, c, c, c, c, c}
	vbroadcastss %xmm3, %ymm7	# ymm7 = {d, d, d, d, d, d, d, d}

	xorq %rcx, %rcx			# i = 0

.Lmap_poly_single_vec_loop:
	cmpq %rdx, %rcx
	jae .Lmap_poly_single_vec_done

	vmovups (%rdi, %rcx, 4), %ymm8	# load 8 float x values

	# result = ((a*x + b)*x + c)*x + d
	vmulps %ymm8, %ymm4, %ymm9	# result = a*x
	vaddps %ymm5, %ymm9, %ymm9	# result = a*x + b

	vmulps %ymm8, %ymm9, %ymm9	# result = (a*x + b)*x
	vaddps %ymm6, %ymm9, %ymm9	# result = (a*x + b)*x + c

	vmulps %ymm8, %ymm9, %ymm9
	vaddps %ymm7, %ymm9, %ymm9	# result = ((a*x+b)*x+c)*x+d

	vmovups %ymm9, (%rsi, %rcx, 4)	# store 8 results

	addq $8, %rcx			# i += 8
	jmp .Lmap_poly_single_vec_loop

.Lmap_poly_single_vec_done:
	vzeroupper
	ret
