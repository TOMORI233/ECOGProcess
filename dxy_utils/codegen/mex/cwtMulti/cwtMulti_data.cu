//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// cwtMulti_data.cu
//
// Code generation for function 'cwtMulti_data'
//

// Include files
#include "cwtMulti_data.h"
#include "rt_nonfinite.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

boolean_T psidft_not_empty;

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131611U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "cwtMulti",                                           // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {1075284325U, 2201364878U, 3488609979U, 1269018621U}, // fSigWrd
    nullptr                                               // fSigMem
};

real_T (*dv1_gpu_clone)[10001];

real_T (*dv_gpu_clone)[95];

// End of code generation (cwtMulti_data.cu)
