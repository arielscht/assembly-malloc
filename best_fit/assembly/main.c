#include <stdio.h>
#include "malloc.h"

int main()
{
    iniciaAlocador();

    void *mem1 = alocaMem(32);
    imprimeMapa();

    void *mem2 = alocaMem(64);
    imprimeMapa();

    void *mem3 = alocaMem(32);
    imprimeMapa();

    void *mem4 = alocaMem(64);
    imprimeMapa();

    liberaMem(mem1);
    imprimeMapa();

    liberaMem(mem3);
    imprimeMapa();

    liberaMem(mem2);
    imprimeMapa();

    liberaMem(mem4);
    imprimeMapa();

    finalizaAlocador();
    return 0;
}
