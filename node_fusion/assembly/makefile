all:
	as malloc.s -o malloc.o -g
	gcc -c main.c -g
	gcc -static main.o malloc.o -o program -g 

avalia:
	as malloc.s -o malloc.o -g
	gcc -c avalia.c -g
	gcc -static avalia.o malloc.o -o avalia -g 

clear:
	rm  *.o

purge: clear
	rm prog