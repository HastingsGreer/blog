There's a sudden swarm of compute intensive projects being written in Python instead of C and its descendants. Specifically, while in performance sensitive, latency sensitive projects C(++) is still king, performance sensitive and throughput sensitive projects are suddenly being written in a language where for loops are 100x slower. 
The core example is of course neural network training. What's going on? Basically, python is both easier to learn for novices, less bug prone for experts, and has a faster interpreter than C++. 

C++ interpreter? Well of course, C is faster than python. But C++, [at least in its earliest implementations](https://en.wikipedia.org/wiki/Cfront), is a turing complete interpreted language that outputs C code. Python has a faster interpreter than C++ template metaprograms, which are python's primary competition. 

# Why every project ends up having a metalanguage and an inner language

What is the fastest way to add 4 numbers in a function? In our dreams, it's

```c
int sum = 0;
for(int i = 0; i < number_elements; i++) {
  sum += *(++array);
}
```
If number_elements is known at compile time, we really want the compiled program to be
```
int sum = *(array)
sum += *(array + 1)
sum += *(array + 2)
sum += *(array + 3)
```

How do we get that? C++ has a wonderful answer. As long as number_elements is a constexpr, the lines of code that compute it are 
# Structure of a High Performance latency insensitive codebase

Typical C Structure:

Metalanguage produces program written in inner language. 
inner program is compiled
inner program processes input metadata
inner program processes input and produces output

Python Structure:

Metalanguage processes input metadata
Metalanguage produces program written in inner language
inner program is compiled
inner program processes input and produces output

# Language diversity vs metalanguage diversity 

High performance C/C++ is many interpreted metalanguages targetting a single high performance compiled language. C++, CMake, m4, autoconf and friends  are all metalanguages that produce C.

High performance python is a single interpreted metalanguage, Python, targetting many high performance compiled languages like torch, jax, tensorflow, sql, and z3. It turns out that 

# Turing completeness

For maintainability, you don't really want your inner program and your metaprogram to both have complex control flow. Traditionally when writing C or C descendants, this has been managed by picking a weak metalanguage like macro substitution, or even just by reprimanding Jimmy from MIT when he submits a pull request that's calculating primes at compile time using SFINAE. 
