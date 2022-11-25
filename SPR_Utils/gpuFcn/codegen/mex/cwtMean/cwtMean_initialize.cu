//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMean_initialize.cu
//
// Code generation for function 'cwtMean_initialize'
//

// Include files
#include "cwtMean_initialize.h"
#include "_coder_cwtMean_mex.h"
#include "cwt.h"
#include "cwtMean_data.h"
#include "rt_nonfinite.h"

// Function Declarations
static void cwtMean_once();

// Function Definitions
static void cwtMean_once()
{
  mex_InitInfAndNan();
  psidft_not_empty_init();
  cudaMalloc(&dv1_gpu_clone, sizeof(real_T[10001]));
  cudaMalloc(&dv_gpu_clone, sizeof(real_T[95]));
}

void cwtMean_initialize()
{
  mexFunctionCreateRootTLS();
  emlrtClearAllocCountR2012b(emlrtRootTLSGlobal, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLicenseCheckR2012b(emlrtRootTLSGlobal,
                          (const char_T *)"distrib_computing_toolbox", 2);
  emlrtLicenseCheckR2012b(emlrtRootTLSGlobal, (const char_T *)"wavelet_toolbox",
                          2);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    cwtMean_once();
  }
  cudaGetLastError();
}

// End of code generation (cwtMean_initialize.cu)
