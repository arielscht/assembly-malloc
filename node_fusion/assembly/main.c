#include "malloc.h"

int main()
{
    iniciaAlocador();

    void *a = alocaMem(16);

    void *b = alocaMem(16);

    void *c = alocaMem(16);

    void *d = alocaMem(16);

    void *e = alocaMem(16);

    void *f = alocaMem(16);

    imprimeMapa();

    liberaMem(b);
    liberaMem(d);

    imprimeMapa();

    liberaMem(e);
    imprimeMapa();

    liberaMem(a);
    imprimeMapa();

    liberaMem(c);
    imprimeMapa();

    liberaMem(f);
    imprimeMapa();

    a = alocaMem(16);
    imprimeMapa();

    liberaMem(a);
    imprimeMapa();

    finalizaAlocador();
    return 0;
}
