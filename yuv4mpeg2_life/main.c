#define F for(i=0;i<l*3;i++)
main(n){int i,j,w=512,l=w*w,o[]={~w,-w,-w+1,-1,1,w-1,w,w+1},b[l*5];F b[i]=rand();for(puts("YUV4MPEG2 W512 H512 C444");puts("FRAME");){F{for(n=j=8;j;n-=b[i+o[--j]]&1);b[i+l]=(n^5&&!b[i]|n^6)-1;}F putchar(b[i]=b[i+l]);}}
