PROGRAM1=hw5_ex1
CC=gcc
CFLAGS=-m32
ASM=nasm
ASMFLAGS=-f elf

all: $(PROGRAM1)

$(PROGRAM1): $(PROGRAM1).o driver.o asm_io.o
	$(CC) $(CFLAGS) $(PROGRAM1).o driver.o asm_io.o -o $(PROGRAM1)

$(PROGRAM1).o: $(PROGRAM1).asm
	$(ASM) $(ASMFLAGS) $(PROGRAM1).asm -o $(PROGRAM1).o

asm_io.o: asm_io.asm
	$(ASM) $(ASMFLAGS) -d ELF_TYPE asm_io.asm -o asm_io.o

driver.o: driver.c
	$(CC) $(CFLAGS) -c driver.c -o driver.o

clean:
	rm -f *.o $(PROGRAM1)
