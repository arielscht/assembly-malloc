#include <stdio.h>
#include "malloc.h"

int main()
{
    iniciaAlocador();

    void *mem1 = alocaMem(20);
    imprimeMapa();

    void *mem2 = alocaMem(30);
    imprimeMapa();

    void *mem7 = alocaMem(10);
    imprimeMapa();

    liberaMem(mem1);
    liberaMem(mem2);
    liberaMem(mem7);
    imprimeMapa();

    void *mem6 = alocaMem(5);

    void *mem3 = alocaMem(3952);
    imprimeMapa();

    void *mem4 = alocaMem(64);
    imprimeMapa();

    void *mem5 = alocaMem(4001);
    imprimeMapa();

    liberaMem(mem1);
    liberaMem(mem3);
    liberaMem(mem4);
    liberaMem(mem5);
    liberaMem(mem6);
    finalizaAlocador();
    return 0;
}
