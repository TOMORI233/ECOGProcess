//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMean_data.h
//
// Code generation for function 'cwtMean_data'
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

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern boolean_T psidft_not_empty;
extern emlrtContext emlrtContextGlobal;
extern real_T (*dv1_gpu_clone)[10001];
extern real_T (*dv_gpu_clone)[95];

// End of code generation (cwtMean_data.h)
