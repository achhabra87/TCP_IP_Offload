#include <stdio.h>
#include "svdpi.h"
#include "dpiheader.h"
int c_task(int ug, int *og)
{
printf("Hello from c_task(1)\n");
printf("Hello from c_task(2)\n");
verilog_task(ug, og); /* Call back into Verilog */
*og = ug;
return(0); /* Return success (required by tasks) */
}
