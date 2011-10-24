#ifndef DES_H_H
#define DES_H_H
#define ENCRYPT 1 
#define DECRYPT 0
typedef struct {
    char *key;
    char *output;
    char *source;
    int encrypt;
    int use_cpu;
}OPT;
void des_ckey(long key,long *store);//生成轮换key
long des(long data,long *ckey,int direction);
#endif
