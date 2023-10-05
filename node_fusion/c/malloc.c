
#include <stdio.h>
#include <unistd.h>
#include "malloc.h"

#define BASE_BLOCK_SIZE 4096
#define CONTROL_SIZE 8

void *initial_brk;
void *logical_heap_end;

long int get_blocks(int bytes)
{
    return (bytes + BASE_BLOCK_SIZE - 1) / BASE_BLOCK_SIZE;
}

void iniciaAlocador()
{
    printf(" \n");
    initial_brk = sbrk(0);
    logical_heap_end = initial_brk;
}

void finalizaAlocador()
{
    brk(initial_brk);
}

int liberaMem(void *block)
{
    void *addr = initial_brk;
    void *heap_end = sbrk(0);
    void *initial_block;

    long int *cur_block_occupied = (long int *)(block - CONTROL_SIZE * 2);
    *cur_block_occupied = 0;

    long int new_size = 0;
    long int blocks_count = 0;
    long int should_update_logical = 0;
    while (addr <= logical_heap_end)
    {
        long int *is_occupied = (long int *)addr;
        long int *block_size = (long int *)(addr + CONTROL_SIZE);

        if (*is_occupied == 0)
        {
            if (new_size == 0)
            {
                initial_block = addr;
                new_size += *block_size;
            }
            else
            {
                new_size += *block_size + CONTROL_SIZE * 2;
            }
            if (addr == logical_heap_end)
            {
                should_update_logical = 1;
            }
            blocks_count += 1;
        }
        else
        {
            if (blocks_count > 1)
            {
                break;
            }
            else
            {
                blocks_count = 0;
                new_size = 0;
            }
        }

        addr += *block_size + CONTROL_SIZE * 2;
    }

    if (blocks_count > 1)
    {
        long int *initial_block_size = (long int *)(initial_block + CONTROL_SIZE);
        *initial_block_size = new_size;

        void *block_end = (long int *)(initial_block + CONTROL_SIZE * 2 + new_size);
        if (should_update_logical == 1)
        {
            logical_heap_end = initial_block;
        }
    }
    return 0;
}

void *alocaMem(int bytes)
{
    void *addr = initial_brk;
    void *heap_end = sbrk(0);
    void *smallest = NULL;
    long int smallest_size = 0;

    while (addr < logical_heap_end)
    {
        long int is_occupied = *(long int *)addr;
        long int block_size = *(long int *)(addr + CONTROL_SIZE);

        if (is_occupied == 0)
        {
            if (block_size >= bytes)
            {
                if (smallest == NULL)
                {
                    smallest_size = block_size;
                    smallest = addr;
                }
                else
                {
                    if (block_size < smallest_size)
                    {
                        smallest_size = block_size;
                        smallest = addr;
                    }
                }
            }
        }
        addr += block_size + CONTROL_SIZE * 2;
    }

    if (smallest == NULL)
    {
        long int new_block_size = bytes + CONTROL_SIZE * 2;
        void *new_logical_end = logical_heap_end + new_block_size;
        void *new_end = new_logical_end + CONTROL_SIZE * 2;
        void *new_heap_end = heap_end;
        if (new_end > heap_end)
        {
            long int diff = new_end - heap_end;
            long int blocks = get_blocks(diff);
            printf("BLOCKS: %ld\n", blocks);
            new_heap_end += BASE_BLOCK_SIZE * blocks;
            brk(new_heap_end);
        }
        else
        {
            printf("BLOCKS: 0\n");
        }

        // Configure the new logical end
        // long int remaining_space = (char *)new_heap_end - (char *)new_logical_end;
        // printf("RE: %ld\n", remaining_space);
        // if (remaining_space >= 16)
        // {
        long int *logical_occupied = (long int *)new_logical_end;
        *logical_occupied = 0;
        long int *logical_size = (long int *)(new_logical_end + CONTROL_SIZE);
        *logical_size = (char *)new_heap_end - (char *)logical_size - CONTROL_SIZE;
        // }

        // Configure the new allocated space
        void *new_addr = logical_heap_end;
        long int *occupied = (long int *)new_addr;
        *occupied = 1;
        long int *size = (long int *)(new_addr + CONTROL_SIZE);
        *size = bytes;
        logical_heap_end = new_logical_end;
        return new_addr + CONTROL_SIZE * 2;
    }
    else
    {
        long int *occupied = (long int *)smallest;
        *occupied = 1;
        return smallest + CONTROL_SIZE * 2;
    }
}

void imprimeMapa()
{
    void *addr = initial_brk;
    void *heap_end = sbrk(0);

    while (addr < heap_end)
    {
        long int is_occupied = *(long int *)addr;
        long int block_size = *(long int *)(addr + CONTROL_SIZE);

        for (int i = 0; i < CONTROL_SIZE * 2; i++)
        {
            printf("#");
        }

        for (int i = 0; i < block_size; i++)
        {
            if (is_occupied)
            {
                printf("+");
            }
            else
            {
                printf("-");
            }
        }

        addr += block_size + CONTROL_SIZE * 2;
    }
    printf("\n");
};