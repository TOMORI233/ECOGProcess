//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMulti_initialize.cu
//
// Code generation for function 'cwtMulti_initialize'
//

// Include files
#include "cwtMulti_initialize.h"
#include "_coder_cwtMulti_mex.h"
#include "cwt.h"
#include "cwtMulti_data.h"
#include "rt_nonfinite.h"

// Function Declarations
static void cwtMulti_once();

// Function Definitions
static void cwtMulti_once()
{
  mex_InitInfAndNan();
  psidft_not_empty_init();
  cudaMalloc(&dv1_gpu_clone, sizeof(real_T[10001]));
  cudaMalloc(&dv_gpu_clone, sizeof(real_T[95]));
}

void cwtMulti_initialize()
{
  mexFunctionCreateRootTLS();
  emlrtClearAllocCountR2012b(emlrtRootTLSGlobal, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLicenseCheckR2012b(emlrtRootTLSGlobal,
                          (const char_T *)"distrib_computing_toolbox", 2);
  emlrtLicenseCheckR2012b(emlrtRootTLSGlobal, (const char_T *)"wavelet_toolbox",
                          2);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    cwtMulti_once();
  }
  cudaGetLastError();
}

// End of code generation (cwtMulti_initialize.cu)
