/* MTI_DPI */

/*
 * Copyright 2002-2012 Mentor Graphics Corporation.
 *
 * Note:
 *   This file is automatically generated.
 *   Please do not edit this file - you will lose your edits.
 *
 * Settings when this file was generated:
 *   PLATFORM = 'linuxpe'
 */
#ifndef INCLUDED_DPIHEADER
#define INCLUDED_DPIHEADER

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"



DPI_LINK_DECL DPI_DLLESPEC
int
c_task(
    int ug,
    int* og);

DPI_LINK_DECL int
verilog_task(
    int ug,
    int* og);

#endif 
