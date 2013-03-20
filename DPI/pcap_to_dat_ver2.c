/*
* Author : Amandeep Chhabra
*
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "svdpi.h"
#include "dpiheader.h"
typedef struct pcap_hdr_s {
        guint32 magic_number;   /* magic number */
        guint16 version_major;  /* major version number */
        guint16 version_minor;  /* minor version number */
        gint32  thiszone;       /* GMT to local correction */
        guint32 sigfigs;        /* accuracy of timestamps */
        guint32 snaplen;        /* max length of captured packets, in octets */
        guint32 network;        /* data link type */
} pcap_hdr_t;

//typedef unsigned char buff_type;
typedef	u_int8_t buff_type;
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



int c_task(int ug, int *og)
{

	FILE *file;
	buff_type *buffer;
	unsigned long fileLen;
	u_int8_t *buff;
	if(argc!=2){
		printf("Please enter the name of pcap file.\nExample for testing.pcap enter: testing \n");
		return 0;
	}

	char inFilestr[80];
   strcpy (inFilestr,argv[1]);
   strcat (inFilestr,".pcap");
	//strcat(argv[1],".pcap");
	//Open file
	file = fopen(inFilestr, "rb");
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
	buffer=(buff_type *)malloc(fileLen+1);
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

  FILE * outFile;
	char *datfile;
	char outFilestr[80];
   strcpy (outFilestr,argv[1]);
   strcat (outFilestr,".dat");

   outFile = fopen (outFilestr,"w");

int byte_counter=0;
uint16_t length=0;
uint16_t packet_byte_counter=0;
int start_packet=1;
  	for(i = 0;i < fileLen;++i){    

	

		if(byte_counter>=24) // not printing global packet header in output file
		{  		

			// checking length of each packet
	 		if(start_packet==1)
	 		{
	 			length=(buffer[i+9]<<8) | buffer[i+8];
	 			length=length+16;
	 			
	 			printf("\nLength %d\n",length); 
	 			start_packet=0;
	 			
	 		}	 			

			if(packet_byte_counter>11) //not printing ts_sec and u_sec in output file
			{

	 		
				buff_type n=buffer[i];
				printf("0x%02x ",(buff_type)n);
				int array[4];
	
				char buf [50];
			 	sprintf (buf, "%02x", n);
				printf("0x");
				int uu;
				uu=0;
	

				hex_to_binary(array,4, buf[0]);
				printf("%d%d%d%d", array[0],array[1],array[2],array[3]);
				fprintf(outFile,"%d%d%d%d", array[0],array[1],array[2],array[3]);
				hex_to_binary(array,4, buf[1]);
				printf("%d%d%d%d", array[0],array[1],array[2],array[3]);
				fprintf(outFile,"%d%d%d%d", array[0],array[1],array[2],array[3]);
				 	printf("\n");
				 	fprintf(outFile,"\n");
				 	printf(" ");
			}
			packet_byte_counter++;
			
 			if(!(packet_byte_counter^length))
 			{
	 				printf("\nLength_matched\n");
	 				length=0;
	 				packet_byte_counter=0;
	 				start_packet=1;
 			}
			
		}
		byte_counter=byte_counter+1;
     }
printf("\n");



 FILE * pFile;
  pFile = fopen ( "myfile.bin" , "wb" );
  fwrite (buffer , 1 , fileLen , pFile );
  fclose (pFile);
	free(buffer);
	printf("Hello from c_task()\n");
verilog_task(ug, og); /* Call back into Verilog */
*og = ug;
 return(0);

}



