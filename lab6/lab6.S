	.section .note.GNU-stack, ""
	.text
	.globl strlen_mine
strlen_mine:
	mov $0, %rcx		# count = 0

loop_strlen_mine:
	cmpb $0, (%rdi)		# compare current byte with '\0'
	je end_strlen_mine 	# if current byte == 0, return

	inc %rcx		# count ++
	inc %rdi		# move pointer to next byte
	jmp  loop_strlen_mine

end_strlen_mine:
	mov %rcx, %rax
	ret

	.globl strlen_utf8
strlen_utf8:
	mov $0, %rcx		# count = 0

loop_strlen_utf8:
	cmpb $0, (%rdi) 	# if current byte == '\0', return
	je end_strlen_utf8

	movb (%rdi), %dl
	andb $0xC0, %dl		# keep only the toptwo bits
	cmpb $0x80, %dl 	# is it 10xxxxx?
	je skip_count_utf8	# if yes, it's continuation, skip

	inc %rcx		# count++

skip_count_utf8:
	inc %rdi		# move pointer to next
	jmp loop_strlen_utf8

end_strlen_utf8:
	mov %rcx, %rax
	ret
