BITS	16
ORG	0x7c00

start:
	cli
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	ss, ax
	mov	gs, ax ; TODO: these might not all be needed, could save some bytes maybe

	xor	bx, bx
	mov	sp, 0x7c00

	; what osdev says to do to enable SSE
	mov	eax, cr0
	and	ax, 0xfffb
	or	ax, 0x2
	mov	cr0, eax
	mov	eax, cr4
	or	ax, 3 << 9
	mov	cr4, eax


	mov	si, msg
	call	puts


	mov	di, password ; user input goes here
input:
	xor	ah, ah
	int	0x16
	stosb
	mov	ah, 0xe
	int	0x10 ; does int10h clobber al? I hope not...
	cmp	di, password+16
	jne	input


	movaps	xmm0, [aes_key]
	movaps	xmm3, [password]

	call	do_aes

	pxor	xmm3, [pw_enc]
	ptest	xmm3, xmm3
	
	je	decs2

	mov	si, oof
	call	puts
	jmp	$

decs2:
	mov	si, stage2
s2loop:
	movaps	xmm0, [password] ; password is now key
	movaps	xmm3, [si]
	call	do_aes
	movaps	[si], xmm3
	add	si, 0x10
	cmp	si, pw_enc
	jne	s2loop

	jmp	stage2

; xmm0 = key
; xmm3 = data
do_aes:
	pxor	xmm2, xmm2
	pxor	xmm3, xmm0

	mov	bl, 0xe5
	mov	cx, 10
	mov	byte [rcon+5], 1

encloop:

rcon:	aeskeygenassist	xmm1, xmm0, 69
	pshufd	xmm1, xmm1, 0b11111111
	shufps	xmm2, xmm0, 0b00010000
	pxor	xmm0, xmm2
	shufps	xmm2, xmm0, 0b10001100
	pxor	xmm0, xmm2
	pxor	xmm0, xmm1
	
	movzx	ax, byte [rcon+5]
	shl	ax, 1
	div	bl
	mov	[rcon+5], ah
	
	loop	next
	aesenclast	xmm3, xmm0
	ret
	
next:	aesenc	xmm3, xmm0
	
	jmp	encloop

puts:
	mov 	ah, 0xe
	lodsb
	test	al, al
	jz	.done
	int	0x10
	jmp	puts
.done:
	ret

msg:
DB	0xd, 0xa, "We upgraded from RC4 this year!", 0xd, 0xa
DB	"Password: ", 0

oof:
DB	0xd, 0xa, "big oof", 0






ALIGN	16


stage2:
	mov	si, winmsg
	call	puts
	jmp	$

winmsg:
DB	0xd, 0xa, 0xd, 0xa, "Wow, 512 bytes is a lot of space, I even had room for this verbose message.", 0xd, 0xa
DB	"I hope you enjoy the rest of AOTW!", 0xd, 0xa
DB	0xd, 0xa, "Anyway, here's your flag: ", 0x1a," AOTW{XXXXXXXXXXXXXXXX} ", 0x1b, 0xd, 0xa
DB	0xd, 0xa, " - Retr0id", 0






TIMES	0x200-0x20-($-$$) \
	DB	0

pw_enc:
DB	247, 254, 26, 128, 54, 81, 56, 144, 160, 52, 17, 109, 48, 94, 82, 84

; Encrypted AAAAs (for testing)
;DB	61, 145, 88, 74, 207, 26, 238, 227, 115, 141, 211, 145, 202, 35, 41, 176

aes_key: ;random bytes + 55aa
DB	109, 121, 128, 185, 165, 10, 151, 36, 13, 45, 252, 54, 13, 149
DB	0x55, 0xAA

password:
