#include <stdio.h>
#include <dlfcn.h>

int main() 
{
    char op[6]; // five chars + null term for op name
    int a, b;   

    while (scanf("%5s %d %d", op, &a, &b) == 3) // run until EOF
    {
        char libname[16]; // buffer for library 

        snprintf(libname, sizeof(libname), "./lib%s.so", op); // build lib filename from op

        void *handle = dlopen(libname, RTLD_NOW); // open library, resolve everything immediately, read all functions from memory
        if (!handle) return 1;
        
        typedef int (*fnptr)(int, int); // fn pointer type, takes 2 ints, returns int

        dlerror(); // clear any previous error
        fnptr fn = (fnptr) dlsym(handle, op); // get function symbol with same name as op
        char *err = dlerror(); // check if error occurred

        if (err) // symbol not found
        {
            dlclose(handle); // close library b4 exiting
            return 1;
        }

        printf("%d\n", fn(a, b));

        dlclose(handle); // close lib to free memory and reset state
    }

    return 0;
}
