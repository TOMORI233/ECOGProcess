//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_cwtMulti_mex.cu
//
// Code generation for function '_coder_cwtMulti_mex'
//

// Include files
#include "_coder_cwtMulti_mex.h"
#include "_coder_cwtMulti_api.h"
#include "cwtMulti_data.h"
#include "cwtMulti_initialize.h"
#include "cwtMulti_terminate.h"
#include "rt_nonfinite.h"

// Function Definitions
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  mexAtExit(&cwtMulti_atexit);
  // Module initialization.
  cwtMulti_initialize();
  // Dispatch the entry-point.
  unsafe_cwtMulti_mexFunction(nlhs, plhs, nrhs, prhs);
  // Module termination.
  cwtMulti_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLSR2021a(&emlrtRootTLSGlobal, &emlrtContextGlobal, nullptr, 1,
                           nullptr);
  return emlrtRootTLSGlobal;
}

void unsafe_cwtMulti_mexFunction(int32_T nlhs, mxArray *plhs[3], int32_T nrhs,
                                 const mxArray *prhs[3])
{
  const mxArray *outputs[3];
  int32_T b_nlhs;
  // Check for proper number of arguments.
  if (nrhs != 3) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal, "EMLRT:runTime:WrongNumberOfInputs",
                        5, 12, 3, 4, 8, "cwtMulti");
  }
  if (nlhs > 3) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal,
                        "EMLRT:runTime:TooManyOutputArguments", 3, 4, 8,
                        "cwtMulti");
  }
  // Call the function.
  cwtMulti_api(prhs, nlhs, outputs);
  // Copy over outputs to the caller.
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }
  emlrtReturnArrays(b_nlhs, &plhs[0], &outputs[0]);
}

// End of code generation (_coder_cwtMulti_mex.cu)
