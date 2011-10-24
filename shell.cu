#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <getopt.h>
#include <sys/stat.h>
#include "des.h"
#include "des_cuda.cuh"

struct option long_options[]={
    {"cpu",0,NULL,0},
    {"gpu",0,NULL,0},
    {NULL,0,NULL,0}
};
OPT initopt(int argc,char **argv);
void process(OPT opt);
void showHelp(char *name)
{
    printf("useage:%s -o output -k keyfile [-e|-d] [--cpu|--gpu] file \n"
            "-o 输出文件\n"
            "-k 密钥文件\n"
            "-e 加密(默认)\n"
            "-d 解密\n"
            "--cpu 使用CPU设备(默认)\n"
            "--gpu 使用GPU设备\n",name);
}
char *unit[5]={" B/s","KB/s","MB/s"};
char *getSpeed(long size,long time)
{
    static char buf[20];
    long s = size/time;
    int u=0;
    while(s>1024){
        s/=1024;
        u++;
    }
    sprintf(buf,"%ld%s",s,unit[u]);
    return buf;
    
}
int main(int argc,char **argv)
{
    if(argc==1){
        showHelp(argv[0]);
        exit(0);
    }
    OPT opt;
    opt = initopt(argc,argv);
    time_t start,end;
    time(&start);
    process(opt);
    time(&end);
    printf("耗时:%ld秒\n",end-start);
    struct stat st;
    stat(opt.source,&st);
    printf("速度:%s\n",getSpeed(st.st_size,end-start));
}
void process(OPT opt)
{
    long k,ckey[16];
    FILE *key = fopen(opt.key,"r");
    fscanf(key,"%lX",&k);
    des_ckey(k,ckey);
    if(!opt.use_cpu){
        printf("使用GPU设备\n");
        des_cuda_opt(opt,ckey);
        return;
    }
    

    printf("使用CPU设备\n");
    int i;
    FILE *in = fopen(opt.source,"rb");
    FILE *out = fopen(opt.output,"wb");
    long buf[256];
    long data,len;
    while(!feof(in)){
        len = fread(&buf,sizeof(long),256,in);
        for(i=0;i<len;i++){
            data = buf[i];
            buf[i] = des(data,ckey,opt.encrypt);
        }
        fwrite(buf,sizeof(long),len,out);
    }
    fclose(key);
    fclose(in);
    fclose(out);
}
OPT initopt(int argc,char **argv)
{
    char ch;
    int option_index;
    OPT opt;
    opt.encrypt = 1;
    opt.use_cpu = 1;
    while((ch = getopt_long(argc,argv,"ho:k:ed",
                    long_options,&option_index))!=-1){
        switch(ch){
            case 0:
                opt.use_cpu = (option_index==0);
                break;
            case 'h':
                showHelp(argv[0]);
                exit(0);
                break;
            case 'o':
                opt.output = optarg;
                break;
            case 'k':
                opt.key = optarg;
                break;
            case 'e':
                opt.encrypt = 1;
                break;
            case 'd':
                opt.encrypt = 0;
                break;
            case '?':
                showHelp(argv[0]);
                exit(0);
                break;
        }
    }
    opt.source = argv[optind];
    return opt;
}
