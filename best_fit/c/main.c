#include "malloc.h"

int main()
{
    iniciaAlocador();

    void *mem1 = alocaMem(16);
    imprimeMapa();

    void *mem2 = alocaMem(64);
    imprimeMapa();

    void *mem3 = alocaMem(3952);
    imprimeMapa();

    void *mem4 = alocaMem(64);
    imprimeMapa();

    void *mem5 = alocaMem(4001);
    imprimeMapa();

    liberaMem(mem1);
    liberaMem(mem2);
    liberaMem(mem3);
    liberaMem(mem4);
    liberaMem(mem5);
    finalizaAlocador();
    return 0;
}
