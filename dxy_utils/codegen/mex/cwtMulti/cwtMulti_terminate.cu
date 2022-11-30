//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMulti_terminate.cu
//
// Code generation for function 'cwtMulti_terminate'
//

// Include files
#include "cwtMulti_terminate.h"
#include "_coder_cwtMulti_mex.h"
#include "cwtMulti_data.h"
#include "rt_nonfinite.h"

// Function Definitions
void cwtMulti_atexit()
{
  mexFunctionCreateRootTLS();
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
  cudaFree(*dv1_gpu_clone);
  cudaFree(*dv_gpu_clone);
}

void cwtMulti_terminate()
{
  cudaError_t errCode;
  errCode = cudaGetLastError();
  if (errCode != cudaSuccess) {
    emlrtThinCUDAError(static_cast<uint32_T>(errCode),
                       (char_T *)cudaGetErrorName(errCode),
                       (char_T *)cudaGetErrorString(errCode),
                       (char_T *)"SafeBuild", emlrtRootTLSGlobal);
  }
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (cwtMulti_terminate.cu)
