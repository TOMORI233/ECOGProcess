//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_cwtMean_api.cu
//
// Code generation for function '_coder_cwtMean_api'
//

// Include files
#include "_coder_cwtMean_api.h"
#include "cwtMean.h"
#include "cwtMean_data.h"
#include "rt_nonfinite.h"

// Function Declarations
static void b_emlrtGPUGetDataVardim(mxGPUArray *r, real_T **r1_data);

static real_T (*b_emlrt_marshallIn(const mxArray *fRange,
                                   const char_T *identifier))[2];

static real_T (*b_emlrt_marshallIn(const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[2];

static real_T c_emlrt_marshallIn(const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static real_T (*d_emlrt_marshallIn(const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[2];

static void emlrtGPUGetDataVardim(mxGPUArray *r, real_T **r1_data);

static real_T emlrt_marshallIn(const mxArray *fs, const char_T *identifier);

static real_T emlrt_marshallIn(const mxArray *u,
                               const emlrtMsgIdentifier *parentId);

// Function Definitions
static void b_emlrtGPUGetDataVardim(mxGPUArray *r, real_T **r1_data)
{
  *r1_data = (real_T *)emlrtGPUGetData(r);
}

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

static void emlrtGPUGetDataVardim(mxGPUArray *r, real_T **r1_data)
{
  *r1_data = (real_T *)emlrtGPUGetData(r);
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

void cwtMean_api(const mxArray *const prhs[3], int32_T nlhs,
                 const mxArray *plhs[3])
{
  static const int32_T d_dims[3]{95, 5001, 64};
  static const int32_T dims[2]{5001, 64};
  static const int32_T b_dims[1]{5001};
  static const int32_T c_dims[1]{95};
  const mxGPUArray *data_gpu;
  mxGPUArray *CData_gpu;
  mxGPUArray *coi_gpu;
  mxGPUArray *f_gpu;
  real_T(*CData_data)[30406080];
  real_T(*data)[320064];
  real_T(*coi)[5001];
  real_T(*f_data)[95];
  real_T(*fRange)[2];
  real_T fs;
  int32_T CData_size[3];
  int32_T f_size[1];
  emlrtInitGPU(emlrtRootTLSGlobal);
  // Marshall function inputs
  data_gpu = emlrt_marshallInGPU(
      emlrtRootTLSGlobal, prhs[0], (const char_T *)"data",
      (const char_T *)"double", false, 2, (void *)&dims[0], true);
  data = (real_T(*)[320064])emlrtGPUGetDataReadOnly(data_gpu);
  fs = emlrt_marshallIn(emlrtAliasP(prhs[1]), "fs");
  fRange = b_emlrt_marshallIn(emlrtAlias(prhs[2]), "fRange");
  // Create GpuArrays for outputs
  coi_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 1,
                                       (void *)&b_dims[0]);
  coi = (real_T(*)[5001])emlrtGPUGetData(coi_gpu);
  // Create GpuArrays for outputs
  f_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 1,
                                     (void *)&c_dims[0]);
  b_emlrtGPUGetDataVardim(f_gpu, (real_T **)&f_data);
  // Create GpuArrays for outputs
  CData_gpu = emlrtGPUCreateNumericArray((const char_T *)"double", false, 3,
                                         (void *)&d_dims[0]);
  emlrtGPUGetDataVardim(CData_gpu, (real_T **)&CData_data);
  // Invoke the target function
  cwtMean(*data, fs, *fRange, *CData_data, CData_size, *f_data, f_size, *coi);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOutGPUVardim(CData_gpu, 3, &CData_size[0]);
  emlrtDestroyGPUArray(CData_gpu);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOutGPUVardim(f_gpu, 1, &f_size[0]);
  }
  emlrtDestroyGPUArray(f_gpu);
  if (nlhs > 2) {
    plhs[2] = emlrt_marshallOutGPU(coi_gpu);
  }
  emlrtDestroyGPUArray(coi_gpu);
  // Destroy GPUArrays
  emlrtDestroyGPUArray(data_gpu);
}

// End of code generation (_coder_cwtMean_api.cu)
