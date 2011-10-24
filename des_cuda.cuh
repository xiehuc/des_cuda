#include "des.h"
#define BLOCK_LENGTH 256 
void des_cuda(long *data,long *ckey,int en);
void des_cuda_opt(OPT opt,long *c_key);
