#include<stdlib.h>
#include<stdint.h>
#include<time.h>
#include<stdio.h>
#include<cuda_profiler_api.h>

#define BLOCK_DIM_X 100
#define BLOCK_DIM_Y 10
#define GRID_DIM_X 500
#define GRID_DIM_Y 50
#define N 5000

// Forward declaration of the kernel function
__global__ void SobelFilter(uint8_t*, uint8_t*);

// Kernel (Runs on Device)
__global__ void SobelFilter(uint8_t* A, uint8_t* B) //You may add more variables to help with writing your code
{
 
// REQD: Find Global Index (Hint: You may use the thread index cheat sheet)
// Start
int blockId = blockIdx.x + blockIdx.y * gridDim.x;
int index = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;

// End

 
// REQD: Write the Kernel Code
// Note: Remember to define all the filter values here (So that it is saved on to the register)
// Start
const int8_t sobel_x[3][3] = {{-1, 0, 1},
                               {-2, 0, 2},
                               {-1, 0, 1}};
const int8_t sobel_y[3][3] = {{-1, -2, -1},
                               { 0,  0,  0},
                               { 1,  2,  1}};

int16_t gradient_x = 0;
int16_t gradient_y = 0;

// if the pixel is on the boundary of the image, skip the calculation...
if (
    index < N || \ // top row
    index >= N * N - N || \ // bottom row
    index % N == 0 || \ // left column
    index % N == N -1 // right column
) {
    B[index] = 0;
} else {
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            gradient_x += A[index + (i * N) + j] * sobel_x[i + 1][j + 1];
            gradient_y += A[index + (i * N) + j] * sobel_y[i + 1][j + 1];
            }
        }
        int16_t gradient = abs(gradient_x) + abs(gradient_y);
    B[index] = (gradient > 255) ? 255 : gradient;
}

// End

}

// Function to read image
__host__ void read_image_file(const char *filename, uint8_t* image) {

    FILE *infile;

    if ((infile = fopen(filename, "r")) == NULL) {
        fprintf(stderr, "Can't open %s\n", filename);
        exit(1);
    }

    for (int y = 0; y < N; y++) {
        for (int x = 0; x < N; x++) {
            fscanf(infile, "%d", &image[y * N + x]);
            // Read and discard the tab or newline character
            char c;
            fscanf(infile, "%c", &c);
	    }
    }

    fclose(infile);
}

// Function to write image
__host__ void write_image_file(const char *filename, uint8_t* image) {
    FILE *outfile;

    if ((outfile = fopen(filename, "w")) == NULL) {
        fprintf(stderr, "Can't open %s\n", filename);
        exit(1);
    }

    for (int y = 0; y < N; y++) {
        for (int x = 0; x < N; x++) {
	        fprintf(outfile, "%d", image[y * N + x]);
            if (x < N - 1) {
                fprintf(outfile, "\t"); // Delimit with tabs within a row
            }
	    }
        fprintf(outfile, "\n"); // Newline between rows
    }

    fclose(outfile);
}

// Main Function (Runs on Host)
int main(int argc, char ** argv)
{

// Step 1: Allocate Host Memory (You may use malloc() to fix any segmentation errors in this part)
int size = N*N*sizeof(uint8_t);
uint8_t* A = (uint8_t*)malloc(size);
uint8_t* B = (uint8_t*)malloc(size);

if (A == NULL || B == NULL) {
    printf("Memory allocation failed.\n");
    return 1;
}

clock_t before_init = clock();
// REQD: Initialize the value of input matrix A (load the values)
// Start
read_image_file(argv[1], A);

// End


for (int i=0; i < N; i++){
	for (int j=0; j < N; j++){
		B[i*N+j] = 0;
	}
}


clock_t after_init = clock();

cudaProfilerStart();
// REQD: Step 2: Allocate device memory for A and B
// Start
uint8_t* d_A;
cudaError_t err = cudaMalloc((void**)&d_A, size);
printf("CUDA malloc d_A: %s\n",cudaGetErrorString(err));
uint8_t* d_B;
err = cudaMalloc((void**)&d_B, size);
printf("CUDA malloc d_B: %s\n",cudaGetErrorString(err));

// End

// Step 3: Copy data from host memory to device memory
cudaEvent_t start_memcpyh2d,stop_memcpyh2d;
cudaEventCreate(&start_memcpyh2d);
cudaEventCreate(&stop_memcpyh2d);


cudaEventRecord(start_memcpyh2d);
// REQD: Code to Copy Data from Host to Device
// Start
err = cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
printf("CUDA Memcpy A->Ad: %s\n",cudaGetErrorString(err));

printf("MEMCPY of %d bytes from Host to Device \n",size);

// End
cudaEventRecord(stop_memcpyh2d);

float mseconds1 = 0.0;
cudaEventElapsedTime(&mseconds1,start_memcpyh2d,stop_memcpyh2d);
printf("Time of the MEMCPY of %d bytes: %2.3f ms\n",size,mseconds1);


// REQD: Setup the execution configuration (Use dim3 objects to setup the Blocks and Grid)
// Start

dim3 dimBlock(BLOCK_DIM_X, BLOCK_DIM_Y);
dim3 dimGrid(GRID_DIM_X, GRID_DIM_Y);


// End

// Step 4: Launch the device computation
cudaEvent_t start_kernel,stop_kernel;
cudaEventCreate(&start_kernel);
cudaEventCreate(&stop_kernel);

cudaEventRecord(start_kernel);
// REQD: Write the kernel call with <<< >>> to launch the GPU device
// Start
SobelFilter<<<dimGrid, dimBlock>>>(d_A, d_B);

// End
cudaEventRecord(stop_kernel);

// Step 4.5: Wait for the Kernel to complete the workload
cudaError_t errk = cudaDeviceSynchronize();
cudaEventSynchronize(stop_kernel);

float mksec = 0.0;
cudaEventElapsedTime(&mksec,start_kernel,stop_kernel);
printf("Time to complete CUDA Sobel kernel %d size: %2.3f ms\n",N,mksec);
printf("CUDA kernel launch: %s\n",cudaGetErrorString(errk));


// Step 5: Read results (matrix B) from the device
cudaEvent_t start_memcpyd2h,stop_memcpyd2h;
cudaEventCreate(&start_memcpyd2h);
cudaEventCreate(&stop_memcpyd2h);
cudaEventRecord(start_memcpyd2h);
// REQD: Write the code to copy result back to the Host (CPU)
// Start
err = cudaMemcpy(B, d_B, size, cudaMemcpyDeviceToHost);
printf("CUDA Memcpy d_B->B: %s\n",cudaGetErrorString(err));

// End
cudaEventRecord(stop_memcpyd2h);

float mseconds2 = 0.0;
cudaEventElapsedTime(&mseconds2,start_memcpyd2h,stop_memcpyd2h);
printf("Time of the MEMCPY of %d bytes : %2.3f ms\n",size,mseconds2);

// REQD: Step 6: Free device memory
// Start
cudaFree(d_A);
cudaFree(d_B);

// End

cudaProfilerStop();

printf("Execution time for initialization(msec) = %d\n",(((after_init-before_init)*1000)/CLOCKS_PER_SEC));
printf("Execution time for CUDA Sobel Filter(msec)= %2.3f\n",mksec);

write_image_file(argv[2], B);

// Free host memory
free(A);
free(B);

return 0;
}	







