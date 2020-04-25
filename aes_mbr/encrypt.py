from Crypto.Cipher import AES

key = b"A"*16
key = b"MiLiT4RyGr4d3MbR"

aes = AES.new(key, AES.MODE_ECB)

mbr = bytearray(open("boot.bin", "rb").read())

S2_START = 0x110
S2_END = 0x1E0

mbr[S2_START:S2_END] = aes.decrypt(mbr[S2_START:S2_END])

open("boot.bin", "wb").write(mbr)
