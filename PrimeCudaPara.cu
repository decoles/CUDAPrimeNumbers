
////////////////////////////////////////////////////////////
//FIND TOTAL PRIME FACTORS IN A RANGE FROM 1 TO N USING CUDA
//CREATED BY DAVID COLES
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
//https://docs.nvidia.com/cuda/index.html SOME CODE MAY BE DERIVED FROM SNIPPETS OF STARTER CODE
//FROM OFFICAL NVIDA DOCUMENTATION
//
// https://mae.ufl.edu/~uhk/QUICK-SEMI-PRIME-FACTORING.pdf for some equations help
//http://compoasso.free.fr/primelistweb/page/prime/liste_online_en.php for comfirming largest prime number
////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h> //FOR FILES
#include <time.h>
//NO CUDA DEPENDENCIES REQUIRED AS WE ARE RUNNING WITH NVCC

//preloads array with all 1's
__global__
void setup(int n, unsigned char *isprime) //Global means it will run with the gpu only Cuts 1 second
{
    int index = blockIdx.x * blockDim.x + threadIdx.x; //Will be each thread in each block
    int stride = blockDim.x * gridDim.x; //Will be equivalent to number of blocks , achieves maximum occupancy on device
    for(int i= index +2; i< n; i+= stride) 
    {  
        isprime[i]=1; //Sets isprime values in the whole array to one except first two
    }
}

//Gets a sum of all Prime numbers within range of 1 billion
__global__
void count(int n, unsigned char *isprime, unsigned int *cnt) //Perform Reduction
{
    int local = 0; //PER THREAD variable
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for(int i= index; i< n; i+= stride) 
    {  
        if(isprime[i]) 
        { 
            local++; //Increment is local to each thread, will get each threads sum
        }
    }
    atomicAdd(cnt, local); //atomicAdd is a function that adds the local value to the global value
    //atomic add works similar to mpi reduce where it takes all the values created and adds them together in one spot
}

//HOST FUNCTION, RUNS ON GPU, since no __global__ specificed it defaults to host.
//Control Number from Wolfram states 50,847,534 is correct number
//Could have __host__ device is other option but can only be called by GPU
int main(void)
{
    double fstart, fstop;
    struct timespec start, stop;
    clock_gettime(CLOCK_MONOTONIC, &start); fstart=(double)start.tv_sec + ((double)start.tv_nsec/1000000000.0);

    int N = 1000000000; // 1 billion
    int  j; //Incrmentor for nested loop
    unsigned int p = 2, cnt = 0; //p is initalizer of the main finder loop
    unsigned char *isprime; //Primary char array that controls the program, has 0 or 1 to signify pnum
    unsigned int *dev_cnt;

    //Will require transfering to GPU to use.
    cudaMalloc((void**)&dev_cnt, sizeof(unsigned int)); //CUDA MALLOC CANNOT ACCESS GPU CODE HERE
    //Cudamaloc required as CPU dosent handle CudaMallocManaged 
    cudaMallocManaged(&isprime,  N * sizeof(unsigned char)); //CPU and GPU accesible
    isprime[0] = 0;
    isprime[1] = 0;
    // Perform setup on GPU with 256 threads
    setup<<<1 , 1024>>>(N, isprime);
    //Kuda kernal Grid size, followed by block size, in this case
    //each block has 1024 threads

    cudaDeviceSynchronize(); //Synchronize the GPU, is needed or Segfault will occur
    //sieve-of-eratosthenes algorithm
    while( (p*p) <=  N) //Cant eaisly paralize becuase its mutualy dependant on the whole array
    {
        //All prime numbers but 2 will be odd
        for(j=2*p; j<N+1; j+=p) 
            isprime[j]=0; // Zero is false turns factors of 2 to false basically deletes it

        // find next lowest prime
        for(j=p+1; j<N+1; j++) //Prime number has to have one other number and 1
        { 
            if(isprime[j]) //if value is one turn p to j not a multiple of 2
            {
                p=j; 
                break; //Exit nested looop
            } 
        }
    }
    for(int i = N; i > 0 ; i--) //Look for largests prime that has been found
    {
        if(isprime[i]) //if prime is true (1) then print the index(the  prime number)
        
        {
            printf("The largest prime to a billion is %d\n", i);
            break; //Largest prime has been found no reason to continue
        }
    }
    cudaMemcpy(dev_cnt, &cnt, sizeof(unsigned int), cudaMemcpyHostToDevice); //Copy to GPU
    //Increasing threads makes proccessed value to small and creates zero
    count<<<4096, 1024>>>(N, isprime, dev_cnt);
    cudaMemcpy(&cnt, dev_cnt, sizeof(unsigned int), cudaMemcpyDeviceToHost); //Copy from GPU
    printf("Total primes from 0 to a billion %d\n", cnt);
    clock_gettime(CLOCK_MONOTONIC, &stop); fstop=(double)stop.tv_sec + ((double)stop.tv_nsec/1000000000.0);
    printf("completed in %lf seconds\n", (fstop-fstart));

    cudaFree(isprime);
    cudaFree(dev_cnt); //Frees cuda memory
    return 0;
}