//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_cwtMulti_api.cu
//
// Code generation for function '_coder_cwtMulti_api'
//

// Include files
#include "_coder_cwtMulti_api.h"
#include "cwtMulti.h"
#include "cwtMulti_data.h"
#include "rt_nonfinite.h"

// Function Declarations
static real_T (*b_emlrt_marshallIn(const mxArray *fRange,
                                   const char_T *identifier))[2];

static real_T (*b_emlrt_marshallIn(const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[2];

static real_T c_emlrt_marshallIn(const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static real_T (*d_emlrt_marshallIn(const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[2];

static real_T emlrt_marshallIn(const mxArray *fs, const char_T *identifier);

static real_T emlrt_marshallIn(const mxArray *u,
                               const emlrtMsgIdentifier *parentId);

// Function Definitions
static real_T (*b_emlrt_marshallIn(const mxArray *fRange,
                                   const char_T *identifier))[2]
{
  emlrtMsgIdentifier thisId;
  real_T(*y)[2];
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(emlrtAlias(fRange), &thisId);
  emlrtDestroyArray(&fRange);
  return y;
}

static real_T (*b_emlrt_marshallIn(const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[2]
{
  real_T(*y)[2];
  y = d_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T c_emlrt_marshallIn(const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  real_T ret;
  emlrtCheckBuiltInR2012b(emlrtRootTLSGlobal, msgId, src,
                          (const char_T *)"double", false, 0U, (void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T (*d_emlrt_marshallIn(const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[2]
{
  static const int32_T dims[2]{1, 2};
  real_T(*ret)[2];
  emlrtCheckBuiltInR2012b(emlrtRootTLSGlobal, msgId, src,
                          (const char_T *)"double", false, 2U,
                          (void *)&dims[0]);
  ret = (real_T(*)[2])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T emlrt_marshallIn(const mxArray *fs, const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(emlrtAlias(fs), &thisId);
  emlrtDestroyArray(&fs);
  return y;
}

static real_T emlrt_marshallIn(const mxArray *u,
                               const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = c_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

void cwtMulti_api(const mxArray *const prhs[3], int32_T nlhs,
                  const mxArray *plhs[3])
{
  static const int32_T b_dims[1]{5001};
  static const int32_T c_dims[1]{95};
  static const int32_T d_dims[1]{5001};
  static const int32_T dims[1]{5001};
  const mxGPUArray *data_gpu;
  mxGPUArray *CData_gpu;
  mxGPUArray *coi_gpu;
  mxGPUArray *f_gpu;
  real_T(*CData)[5001];
  real_T(*coi)[5001];
  real_T(*data)[5001];
  real_T(*f)[95];
  real_T(*fRange)[2];
  real_T fs;
  emlrtInitGPU(emlrtRootTLSGlobal);
  // Marshall function inputs
  data_gpu = emlrt_marshallInGPU(
      emlrtRootTLSGlobal, prhs[0], (const char_T *)"data",
      (const char_T *)"double", false, 1, (void *)&dims[0], true);
  data = (real_T(*)[5001])emlrtGPUGetDataReadOnly(data_gpu);
  fs = emlrt_marshallIn(emlrtAliasP(prhs[1]), "fs");
  fRange = b_emlrt_marshallIn(emlrtAlias(prhs[2]), "fRange");
  // Create GpuArrays for outputs
  coi_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 1,
                                       (void *)&b_dims[0]);
  coi = (real_T(*)[5001])emlrtGPUGetData(coi_gpu);
  // Create GpuArrays for outputs
  f_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 1,
                                     (void *)&c_dims[0]);
  f = (real_T(*)[95])emlrtGPUGetData(f_gpu);
  // Create GpuArrays for outputs
  CData_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 1,
                                         (void *)&d_dims[0]);
  CData = (real_T(*)[5001])emlrtGPUGetData(CData_gpu);
  // Invoke the target function
  cwtMulti(*data, fs, *fRange, *CData, *f, *coi);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOutGPU(CData_gpu);
  emlrtDestroyGPUArray(CData_gpu);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOutGPU(f_gpu);
  }
  emlrtDestroyGPUArray(f_gpu);
  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOutGPU(coi_gpu);
  }
  emlrtDestroyGPUArray(coi_gpu);
  // Destroy GPUArrays
  emlrtDestroyGPUArray(data_gpu);
}

// End of code generation (_coder_cwtMulti_api.cu)
