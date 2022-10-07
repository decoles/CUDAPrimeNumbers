##CUDA program to find the sum of all prime numbers up to one billion.
      
to compile nvcc PrimeCuda.cu -o Seq <-O3> //To speed up for sequtial
```
./Seq to run
```
to comile Parallel Cuda portion nvcc PrimeCudaPara.cu -o Para <-O3> //O3 is option as with the previous
```
./Para to run
```
