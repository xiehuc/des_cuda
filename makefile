all:des 

des:des.c shell.cu des_cuda.cu
	nvcc -c shell.cu des.c
	nvcc -c des_cuda.cu -o des_cuda.o
	nvcc des_cuda.o des.o shell.o -o des
