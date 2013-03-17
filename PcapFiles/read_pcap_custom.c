#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

void hex_to_binary(int array[4],int size, char buf)
{
	
	switch( buf ) 
	{
		case '0':
		
		    array[0]=0;
		     array[1]=0;
		     array[2]=0;
			 array[3]=0;
			 break;
 		case '1':
		    array[0]=0;
		     array[1]=0;
		     array[2]=0;
			 array[3]=1;
			 break;
			 
		case '2':
			array[0]=0;
			array[1]=0;
			array[2]=1;
			array[3]=0;
		break;
			
		case '3':
			array[0]=0;
			array[1]=0;
			array[2]=1;
			array[3]=1;
		break;	
			
		case '4':
			array[0]=0;
			array[1]=1;
			array[2]=0;
			array[3]=0;
		break;	
		case '5':
			array[0]=0;
			array[1]=1;
			array[2]=0;
			array[3]=1;
		break;	
			
		case '6':
			array[0]=0;
			array[1]=1;
			array[2]=1;
			array[3]=0;
		break;
		case '7':
			array[0]=0;
			array[1]=1;
			array[2]=1;
			array[3]=1;
		break;
		case '8':
		    array[0]=1;
		     array[1]=0;
		     array[2]=0;
			 array[3]=0;
 		break;
 		case '9':
		    array[0]=1;
		     array[1]=0;
		     array[2]=0;
			 array[3]=1;
		break;	 	 
		case 'a':
			array[0]=1;
			array[1]=0;
			array[2]=1;
			array[3]=0;
		break;		
		case 'b':
			array[0]=1;
			array[1]=0;
			array[2]=1;
			array[3]=1;
		break;	
			
		case 'c':
			array[0]=1;
			array[1]=1;
			array[2]=0;
			array[3]=0;
		break;	
		case 'd':
			array[0]=1;
			array[1]=1;
			array[2]=0;
			array[3]=1;
		break;	
			
		case 'e':
			array[0]=1;
			array[1]=1;
			array[2]=1;
			array[3]=0;
		break;
		case 'f':
			array[0]=1;
			array[1]=1;
			array[2]=1;
			array[3]=1;	
		break;
	}

} 

int main(int argc, char *argv[])
{

	FILE *file;
	unsigned char *buffer;
	unsigned long fileLen;
	u_int8_t *buff;


	//Open file
	file = fopen("PcapFiles/dat4.pcap", "rb");
	if (!file)
	{
		fprintf(stderr, "Unable to open file %s", "test.cap");
		return;
	}
	
	//Get file length
	fseek(file, 0, SEEK_END);
	fileLen=ftell(file);
	fseek(file, 0, SEEK_SET);

	//Allocate memory
	buffer=(unsigned char *)malloc(fileLen+1);
	if (!buffer)
	{
		fprintf(stderr, "Memory error!");
                                fclose(file);
		return;
	}

	//Read file contents into buffer
	fread(buffer, fileLen, 1, file);
	fclose(file);

	//Do what ever with buffer
	int i;

  	for(i = 0;i < fileLen;++i){     
  	
	  	if(i%18==0)
		 {
		 	printf("\n");
		 }
 	/*
     printf("0x%x 0x%x 0x%x 0x%x ",(((u_int *)buffer)[i] <<24)>>24, ((((u_int *)buffer)[i] <<16)&0xFF000000)>>24, ((((u_int *)buffer)[i] )&0x00FF0000)>>16,((u_int *)buffer)[i] >>24);*/

	//printf("0x%x ",((unsigned char *)buffer[i])); 
	u_int8_t n=buffer[i]&0xFF;
	//printf("0x%02x ",(u_int8_t)n);
	int array[4];
	
	
	char buf [50];
 	sprintf (buf, "%02x", n);
  printf ("[ %s ] %x  %x \n",buf,buf[0],buf[1]);
	printf("0x");
	int uu;
	uu=0;
	hex_to_binary(array,4, buf[0]);
	printf("%d %d %d %d", array[0],array[1],array[2],array[3]);
	hex_to_binary(array,4, buf[1]);
	printf("%d%d%d%d", array[0],array[1],array[2],array[3]);
		printf(" ");
     }
printf("\n");
 FILE * pFile;
  pFile = fopen ( "myfile.bin" , "wb" );
  fwrite (buffer , 1 , sizeof(buffer) , pFile );
  fclose (pFile);
	free(buffer);
}



