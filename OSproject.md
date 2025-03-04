@def title = "OS Project"
There are various memory allocators and memory management strategies floating around

Goal: make a memory allocator where the primary metric is that it should be easy to reason about for the compiler. Easy to reason about encourages inlining, inlining encourages vectorization




We go so far as to

(Why float**? want compiler to track alignment)
```
typedef float** allocator;

float* alloc(allocator s, unsigned int size_floats) {
     *s = *s - size_floats;
     return *s
}
```

Then, instead of paying the price of allocating while we are allocating, we build scaffolding using operating system and hardware features to make the above safe.

First, how do we free memory? Never free, just discard allocators

```
#define allocator_push( old_allocator, new_allocator ) \
float * stack_allocator_storage = * old_allocator; \
allocator new_allocator = &stack_allocator_storage;
```
All functions will just assume that they will get an allocator as the first argument.

How do we expand memory? There are two options: On the one hand, we could never expand memory, and instead always initially allocate memory equal to the the size of physical memory. This will actually get claimed as it is written to. In this case, responding to the allocator filling up is responsibility of the operating system- neither the program nor the compiler know about it.
Now our enemy is the OOM killer: malloc failing was friendly and catchable, the oom killer is mysterious and will start deleting processes as we write to too many pages in the allocated block.

Second option: allocate jus ta little memory at first, and catch the segfault from writing after the end of the allocated memory and expand it. I think that this is less demanding of system resources (especially if huge pages aren't turned on). It will require modifying malloc to reserve a section of virtual address space. since it requires controlling the virtual address space to forbid putting anything in the way of where the bump allocator could expand.


Basically, this is just a second stack. A motivating code sample for why bump allocators have huge ergonomic advantages: it works with array-programming habits I have from python.

```
//branchless bump allocator differential equation integration
matrix rk4(allocator source, vector (*dydt)(allocator, vector), vector y, float h,
           float tfinal) {
  float t = 0;
  matrix output = new_matrix(source, y.len, tfinal / h, NULL);
  int i = 0;
  allocator_push(source, is)

  while (t < tfinal - h) {
    t += h;
    vector k1 = dydt(is, y);
    vector step = k1;
    vector k2 = dydt(is, add_vv(is, y, mul_vs(is, k1, h / 2)));
    step = add_vv(is, step, mul_vs(is, k2, 2));
    vector k3 = dydt(is, add_vv(is, y, mul_vs(is, k2, h / 2)));
    step = add_vv(is, step, mul_vs(is, k3, 2));
    vector k4 = dydt(is, add_vv(is, y, mul_vs(is, k3, h)));
    step = add_vv(is, step, k4);

    step = mul_vs(is, step, h / 6.);
    y = add_vv(is, y, step);
    set_col(output, y, i);

    // This is a little dodgy- reset 
    stack_allocator_storage = *old_allocator;

    y = get_col(is, output, i);
    i += 1;
  }

  return output;
}

```
Whereas, with the math functions allocating their return values, freeing is an absolute burden. (This is what RAII is for, of course,
so the real question is whether there will be big performance gains.)
```
//glibc Malloc based differential equation integration
matrix rk4(allocator source, vector (*dydt)(vector), vector y, float h,
           float tfinal) {
  float t = 0;
  matrix output = new_matrix(source, y.len, tfinal / h, NULL);
  int i = 0;

  while (t < tfinal - h) {
    t += h;
    vector k1 = dydt(y);
    vector step = k1;
    vector scaled_k1 = mul_vs(k1, h / 2);
    vector y_plus_scaled_k1 = add_vv(scaled_k1, y);
    vector k2 = dydt(y_plus_scaled_k1);
    vector two_k2 = mul_vs(k2, 2);
    vector step2 = add_vv(step, scaled_k2);
    vector scaled_k2 = mul_vs(k2, h / 2);
    vector y_plus_scaled_k2 = add_vv(y, scaled_k2);
    vector k3 = dydt(y_plus_scaled_k2);
    vector two_k3 = mul_vs(k3, 2);
    vector step3 = add_vv(step2, two_k3);
    vector scaled_k3 = mul_vs(k3, h);
    vector y_plus_scaled_k3 = add_vv(y, scaled_k3);
    vector k4 = dydt(y_plus_scaled_k3);
    vector step4 = add_vv(is, step, k4);

    vector scaled_step = mul_vs(step, h / 6.);
    vector new_y = add_vv(y, scaled_step);
    set_col(output, new_y, i);

    // memory management
	free_vector(k1 );
	free_vector(step );
	free_vector(scaled_k1 );
	free_vector(y_plus_scaled_k1 );
	free_vector(k2 );
	free_vector(two_k2 );
	free_vector(step2 );
	free_vector(scaled_k2 );
	free_vector(y_plus_scaled_k2 );
	free_vector(k3 );
	free_vector(two_k3 );
	free_vector(step3 );
	free_vector(scaled_k3 );
	free_vector(y_plus_scaled_k3 );
	free_vector(k4 );
	free_vector(step4 );
	free_vector(vector );
	free_vector(new_y );
    y = get_col(is, output, i);
    i += 1;
  }

  return output;
}

```






Preliminary experiments: 

As a first pass, we can confirm that at least the compiler is much happier reasoning about this memory allocation approach than the glibc malloc. We write a program to add two hardcoded vectors, and return the first element of the result:

```
#include <stdlib.h>
typedef struct {
    float* data;
    int len;
} vector;

typedef float** allocator;
float* alloc( allocator s, int len) {
    *s = *s - len;
    return *s;
}

vector add (allocator s, vector a, vector b) {
    vector res;
    res.data = alloc(s, a.len);
    for(int i = 0; i < a.len; i++) {
        res.data[i] = a.data[i] + b.data[i];
    }
    return res;
}

vector vec(allocator s, int len, float* data) {
    vector res;
    res.data = alloc(s, len);
    res.len = len;
    for(int i = 0; i < len; i++){
    res.data[i] = data[i];
    }
    return res;
}

int main() {

    float* memory = malloc(1000 * sizeof(float));
    float* float_ptr = memory + 1000;
    allocator s = &float_ptr;
    
    vector a = vec(s, 2, (float[]){1, 2});
    vector b = vec(s, 2, (float[]){3, 4});
    vector c = add(s, a, b);
    int ret = (int) c.data[0];
    free(memory);
    return ret;

}
```
gcc happily compiles this to

```
main:
        mov     eax, 4
        ret
```

This is in contrast to the analogous program using a real allocator:

```
#include <stdlib.h>
typedef struct {
    float* data;
    int len;
} vector;


vector add (vector a, vector b) {
    vector res;
    res.data = malloc(a.len * sizeof(float));
    for(int i = 0; i < a.len; i++) {
        res.data[i] = a.data[i] + b.data[i];
    }
    return res;
}

vector vec(int len, float* data) {
    vector res;
    res.data = malloc(len * sizeof(float));
    res.len = len;
    for(int i = 0; i < len; i++){
    res.data[i] = data[i];
    }
    return res;
}

int main() {
    vector a = vec(2, (float[]){1, 2});
    vector b = vec(2, (float[]){3, 4});
    vector c = add(a, b);
    int ret = (int) c.data[0];
    free(a.data);
    free(b.data);
    free(c.data);
    return ret;

}
```
which gcc can no longer inline, producing a bunch of function calls etc

```
main:
        push    r13
        mov     edi, 2
        push    r12
        push    rbp
        push    rbx
        sub     rsp, 24
        mov     rax, QWORD PTR .LC0[rip]
        mov     rsi, rsp
        mov     QWORD PTR [rsp], rax
        call    vec
        lea     rsi, [rsp+8]
        mov     edi, 2
        mov     r12, rax
        mov     rax, QWORD PTR .LC1[rip]
        mov     rbx, rdx
        mov     QWORD PTR [rsp+8], rax
        call    vec
        mov     rsi, rbx
        mov     rdi, r12
        mov     rcx, rdx
        mov     rdx, rax
        mov     rbp, rax
        call    add
        mov     rdi, r12
        cvttss2si       r13d, DWORD PTR [rax]
        mov     rbx, rax
        call    free
        mov     rdi, rbp
        call    free
        mov     rdi, rbx
        call    free
        add     rsp, 24
        pop     rbx
        mov     eax, r13d
        pop     rbp
        pop     r12
        pop     r13
        ret
```

I have spent the remaining pre-project time fussing about with what it's like to program C in this style, by writing a toy physics engine. This is not yet science, but it's given me a sense of what features will need to be implemented.  

The big annoyance so far is a lack of an ergonomic growable array.
Runtime checks and logging in debug mode are absolutely critical. With the debug ifdefs turned on, the allocator struct currently looks less like **float and more like

```
typedef struct {
  float *start;
  float *current;
  float *end;
  char do_logging;
} allocator_storage;
typedef allocator_storage * allocator;
```

The target expermiments will be running workload such as the toy physics simulator in three parallel implementations: the branchless allocation approach here, raii style mallocing and freeing, and hard coding vector length and then moving everything to the stack.

I whacked compiled it into web assembly which lets me embed it into this proposal, which has to be worth something.
