all:
	as malloc.s -o malloc.o -g
	gcc -c main.c -g
	gcc -static main.o malloc.o -o program -g 


clear:
	rm  *.o

purge: clear
	rm program