#include <stdio.h>

int global = 42;

int foo(int x) {
    return x + global;
}

int main() {
    printf("foo(1) = %d\n", foo(1));
    return 0;
}
