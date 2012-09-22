
#include <stdio.h>
#include <stdlib.h> 

unsigned char memory[1024*16];

int main (int argc, char **argv)
{
    FILE *input_file;
    char str[4096];
    char* pstr=&str[0];
    int i,j,n;
    unsigned int adr,val;

    for(i=0; i<sizeof(memory); i++)
	memory[i]=0;

    input_file = fopen(argv[1],"rb");
    if(input_file==NULL) {
      printf("%s ERROR: Can't open %s. Quitting\n", argv[0], argv[1]);
      exit(1);
    }
    printf("#input file %08X\n",(unsigned int)input_file);
    printf("WIDTH = 32;\n");
    printf("DEPTH = 2048;\n");
    printf("ADDRESS_RADIX = HEX;\n");
    printf("DATA_RADIX = HEX;\n");
    printf("CONTENT BEGIN\n");

    while(1)
    {
	if(feof(input_file))
	    break;
	str[0]=0;
	fgets(str,1024,input_file);
	//printf("> %s",str);
	if(str[0]=='/')
	    continue;
	n=sscanf(str,"@%08X %08X",&adr,&val);
	//printf("%d %08X %08X\n",n,adr,val);
	if(n==2)
	{
	    unsigned int* ptr = (unsigned int*)&memory[adr];
	    ptr[0]=val;
	}
    }

    fclose(input_file);
    
    //for(i=0; i<512; i++)
    for(i=0; i<2048; i++)
    {
	printf("%08X: ",i);
	//for(j=15; j>=0; j--)
	//    printf("%02X",memory[i*16+j]);
	for(j=3; j>=0; j--)
	    printf("%02X",memory[i*4+j]);
	printf(";\n");
    }
    printf("END\n");
}


