//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMulti.h
//
// Code generation for function 'cwtMulti'
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
void cwtMulti(const real_T data[5001], real_T fs, const real_T fRange[2],
              real_T CData[5001], real_T f[95], real_T coi[5001]);

// End of code generation (cwtMulti.h)
