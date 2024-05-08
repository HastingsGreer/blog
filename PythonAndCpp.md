There's a sudden swarm of compute intensive projects being written in Python instead of C++. Specifically, while in performance sensitive, latency sensitive projects C++ is still king, incredibly compute intensive and throughput sensitive projects
(Mostly I mean neural network training) are now completely dominated by python. What's going on? Basically, python is both easier to learn for novices, less bug prone for experts, and has a faster interpreter than C++. 

Specifically, python has a faster interpreter than C++ template metaprograms, which are the C++ programs python is actually competing with.

What is the fastest way to add 5 numbers in a C++ function? In our dreams, it's

```c
int sum = 0;
for(int i = 0; i < number_elements; i++) {
  sum += *(++array);
}
```
and we assume that the compiler is going to unroll that baby. In practice however, we can't guarantee that the compiler will catch on, and so technically
```
sum = *(array) + *(array + 1) + *(array + 2) + *(array + 3) ...
```
is going to win, especially as the complexity of the operations that need unrolling scale. If we're writing a neural network 
