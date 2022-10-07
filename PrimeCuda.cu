#include <stdio.h>
#include <time.h>  
#include <time.h>
#define MAX (1000000000)
//THIS RUNS SEQUENTIAL ON THE CPU
unsigned char isprime[MAX+1]; //sets isprime array with a billion values
//unsigned int value[MAX+1];  
//Value does not serve any known purpose. Results do not change when it is removed
//
int main(void)
{
    const int N = 1000000000;
    double fstart, fstop;
    struct timespec start, stop;
    clock_gettime(CLOCK_MONOTONIC, &start); fstart=(double)start.tv_sec + ((double)start.tv_nsec/1000000000.0);

    // unsigned char *isprime;
    // malloc(&isprime,  N * sizeof(unsigned char));
    int i, j;
    unsigned int p=2, cnt=0;
    // not prime by definition
    isprime[0]=0; 
    isprime[1]=0; 
    //Itertes through a billion
    for(i=2; i<MAX+1; i++) 
    {  
        isprime[i]=1; //Sets isprime values in the whole array to one
        //sets whole array to true
       
    }
    //Each time the while roop iterates and visits the for loop  
    //Will increases 
    //p starts as 2 will be 4 initally

    while( (p*p) <=  MAX) 
    {
        // invalidate all multiples of lowest prime so far
        //Essentially removes any non prime numbers
        // Will run over and over, finds prime numbers 
        //Loops are always checking if a prime number or not and will elimniate 
        //when found not to be prime
        //This proccess is much quicker than the other ways of doing things.
        for(j=2*p; j<MAX+1; j+=p) 
            isprime[j]=0; // Zero is false turns factors of 2 to false

        // find next lowest prime
        for(j=p+1; j<MAX+1; j++) 
        { 
            if(isprime[j]) 
            {
                p=j; 
                break; 
            } 
        }
    }
    for(i=0; i<MAX+1; i++) { if(isprime[i]) { cnt++; } }  //Counter, gets a count when isprime is true
    for(i = N; i > 0 ; i--) //Look for largests prime that has been found
    {
        if(isprime[i]) 
        {
            printf("The largest prime to a billion is %d\n", i);
            break;//Largest prime has been found no reason to continue
        }
    }
    //Above scans isPrime array and if i  [i] is true it will increment
    //count, giving us our total number of prime numbers
    printf("\nNumber of primes [0..%d]=%u\n\n", MAX, cnt);
    //Gets end time.
    clock_gettime(CLOCK_MONOTONIC, &stop); fstop=(double)stop.tv_sec + ((double)stop.tv_nsec/1000000000.0);
    printf("completed in %lf seconds\n", (fstop-fstart));
    return 0;
}