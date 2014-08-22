gpu = gpuDevice(1);
reset(gpu);

% Run system command
% Linux example
!nvcc -v -g -gencode=arch=compute_30,code=sm_30 -c cudaDecorrelateFeature.cu -Xcompiler -fPIC -I/afs/cs/package/matlab-r2013b/matlab/r2013b/extern/include -I/afs/cs/package/matlab-r2013b/matlab/r2013b/toolbox/distcomp/gpu/extern/include
mex cudaDecorrelateFeature.o -L/usr/local/cuda-6.0/lib64 -L/afs/cs/package/matlab-r2013b/matlab/r2013b/bin/glnxa64 -lcudart -lcublas -lmwgpu


% Mac error fix example
if ismac
  !rm mexGPUExample.o mexGPUExample.mexmaci64
  !nvcc -v -O3 -DNDEBUG  -Xcompiler -fPIC -I/Applications/MATLAB_R2014a.app/extern/include -I/Applications/MATLAB_R2014a.app/toolbox/distcomp/gpu/extern/include -c mexGPUExample.cu
  % Use default cuda in MATLABROOT/bin/maci64/
  mex -v -largeArrayDims mexGPUExample.o -I/usr/local/cuda/include -L/Applications/MATLAB_R2014a.app/bin/maci64  -lcudart -lcufft -lmwgpu

  % If we use CUDA lib, it fails to find rpath.
  % mex -v mexGPUExample.o  -L/usr/local/cuda/lib -L/Applications/MATLAB_R2014a.app/bin/maci64 -lcudart -lcufft -lmwgpu
  % !install_name_tool -change @rpath/libcufft.6.0.dylib /usr/local/cuda/libcufft.dylib mexGPUExample.mexmaci64
  % !install_name_tool -change @rpath/libcudart.6.0.dylib /usr/local/cuda/libcudart.dylib mexGPUExample.mexmaci64

  mexGPUExample(gpuArray(ones(24)))
end