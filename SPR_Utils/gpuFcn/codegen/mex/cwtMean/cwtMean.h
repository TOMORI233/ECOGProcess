//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMean.h
//
// Code generation for function 'cwtMean'
//

#pragma once

// Include files
#include "rtwtypes.h"
#include "emlrt.h"
#include "mex.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// Custom Header Code

#ifdef __CUDA_ARCH__
#undef printf
#endif

// Function Declarations
void cwtMean(const real_T data[320064], real_T fs, const real_T fRange[2],
             real_T CData_data[], int32_T CData_size[3], real_T f_data[],
             int32_T f_size[1], real_T coi[5001]);

// End of code generation (cwtMean.h)
