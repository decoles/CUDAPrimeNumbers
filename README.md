## CUDA program to find the sum of all prime numbers up to one billion.
      
To compile sequential CUDA portion.
```
nvcc PrimeCuda.cu -o Seq <-O3> #To speed up for sequtial
```
To run sequential using CUDA.
```
./Seq to run
```
To compile Parallel Cuda portion .
```
nvcc PrimeCudaPara.cu -o Para <-O3> #O3 is option as with the previous
```
To run Parallel.
```
./Para 
```
