	.data
seed: 
	.quad 1			# uint64_t seed = 1;

	.text
	.globl randint
randint: 
	movabs $6364136223846793005, %rdx	# mult = 6364136223846793005;
	mov seed(%rip), %rax			# rax = seed;
	imul %rdx, %rax				# rax *= mult;
	add $1, %rax				# rax += 1;
	mov %rax, seed(%rip)			# seed = rax;
	shr $33, %rax				# rax = seed >> 33;
	ret					# return;

	.globl fill_array
fill_array:
	test %rsi, %rsi			# if (len == 0)
	je .Lfill_done			# return;

	sub $8, %rsp			# align stack before call

.Lfill_loop:
	call randint			# rax = randing();
	and $0xff, %rax			# rax = rax & 0xff;
	sub $128, %rax			# rax = rax - 128;

	mov %rax, (%rdi)		# *array = rax;
	add $8, %rdi			# array++;

	dec %rsi			# len--;
	jne .Lfill_loop			# if (len != 0) repeat;

	add $8, %rsp			# restore stack

.Lfill_done:
	ret				# return

	.globl dot
dot: 
	mov $0, %rax			# int64_t sum = 0;
	test %rdx, %rdx			# if (n == 0)
	je .Ldot_done			# return sum;

.Ldot_loop:
	mov (%rdi), %rcx		# rcx = *arr1;
	imul (%rsi), %rcx		# rcx *= *arr2;
	add %rcx, %rax			# sum += rcx;

	add $8, %rdi			# arr1++;
	add $8, %rsi			# arr2++;

	dec %rdx			# n--;
	jne .Ldot_loop			# if (n != 0) repeat;

.Ldot_done:
	ret				# return sum;


        .globl dot_struct
dot_struct:
        mov $0, %rax                    # int64_t sum = 0;
        test %rsi, %rsi                 # if (n == 0)
        je .Ldot_struct_done            # return sum;

.Ldot_struct_loop:
        mov (%rdi), %rcx                # rcx = pairs[i].a;
        imul 8(%rdi), %rcx              # rcx *= pairs[i].b;
        add %rcx, %rax                  # sum += rcx;

        add $16, %rdi                   # pairs++;
        dec %rsi                        # n--;
        jne .Ldot_struct_loop           # if (n != 0) repeat;

.Ldot_struct_done:
        ret                             # return sum;
