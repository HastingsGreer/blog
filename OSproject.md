There are various memory allocators and memory management strategies floating around

Goal: make a memory allocator where the primary metric is that it should be easy to reason about for the compiler. Easy to reason about encourages inlining, inlining encourages vectorization




We go so far as to

(Why float**? want alignment)
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

How do we expand memory? Never expand memory, always initially allocate memory the size of physical memory. Now, getting new memory is the responsibility of the operating system- compiler doesn't know about it.

Now our enemy is the OOM killer: malloc failing was friendly and catchable, the oom killer is mysterious and will start wrecking things 
