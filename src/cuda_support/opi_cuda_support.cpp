#include "../OPI/internal/opi_cudasupport.h"

#include <cuda_runtime.h>
#include <iostream>

using namespace std;

class CudaSupportImpl:
		public OPI::CudaSupport
{
	public:
		CudaSupportImpl();
		~CudaSupportImpl();

		virtual void init();

		virtual void copy(void* a, void* b, size_t size, bool host_to_device);
		virtual void allocate(void** a, size_t size);
		virtual void free(void* mem);
		virtual void shutdown();
		virtual void selectDevice(int device);
		virtual int getCurrentDevice();
		virtual int getDeviceCount();
		virtual cudaDeviceProp* getDeviceProperties(int device);
	private:
		cudaDeviceProp* CUDAProperties;
};

CudaSupportImpl::CudaSupportImpl()
{
	CUDAProperties = 0;
}

CudaSupportImpl::~CudaSupportImpl()
{
	delete[] CUDAProperties;
}

void CudaSupportImpl::init()
{
	int deviceCount = 0;
	int deviceNumber = 0;

	// search for devices and print some information
	// currently, only the first device is used
	cudaGetDeviceCount(&deviceCount);
	if (deviceCount == 0) {
		cout << "  No CUDA-capable devices found." << endl;
	}
	else {
		CUDAProperties = new cudaDeviceProp[deviceCount];
		cout << "  Found " << deviceCount << " CUDA capable device(s): " << endl << endl;
		for (int i=0; i<deviceCount; i++) {
			cudaGetDeviceProperties(&(CUDAProperties[i]), i);
			cudaDeviceProp& deviceProp = CUDAProperties[i];
			int tpb = deviceProp.maxThreadsPerBlock;
			int bs[3];
			int gs[3];
			for (int j=0; j<3; j++) {
				bs[j] = deviceProp.maxThreadsDim[j];
				gs[j] = deviceProp.maxGridSize[j];
			}
			cout << "  Device Number:      " << i << endl;
			cout << "  Name:               " << deviceProp.name << endl;
			cout << "  Compute Capability: " << deviceProp.major << "." << deviceProp.minor << endl;
			cout << "  Total Memory:       " << (deviceProp.totalGlobalMem/(1024*1024)) << "MB" << endl;
			cout << "  Clock Speed:        " << (deviceProp.clockRate/1000) << "MHz" << endl;
			cout << "  Threads per Block:  " << tpb << endl;
			cout << "  Block Dimensions:   " << bs[0] << "/" << bs[1] << "/" << bs[2] << endl;
			cout << "  Grid Dimensions:    " << gs[0] << "/" << gs[1] << "/" << gs[2] << endl;
			cout << "  Warp Size:          " << deviceProp.warpSize << endl;
			cout << "  MP Count:           " << deviceProp.multiProcessorCount << endl;
			cout << endl;
		}

		deviceNumber = 0;

		cudaSetDevice(deviceNumber);
	}
}

void CudaSupportImpl::allocate(void** a, size_t size)
{
	cudaMalloc(a, size);
}

void CudaSupportImpl::free(void *mem)
{
	cudaFree(mem);
}

void CudaSupportImpl::copy(void *destination, void *source, size_t size, bool host_to_device)
{
	cudaMemcpy(destination, source, size, host_to_device ? cudaMemcpyHostToDevice : cudaMemcpyDeviceToHost);
}

void CudaSupportImpl::shutdown()
{
	cudaThreadExit();
}

void CudaSupportImpl::selectDevice(int device)
{
	int deviceCount = 0;
	cudaGetDeviceCount(&deviceCount);
	if( device < deviceCount);
		cudaSetDevice(device);
}

int CudaSupportImpl::getCurrentDevice()
{
	int device;
	cudaGetDevice(&device);
	return device;
}

int CudaSupportImpl::getDeviceCount()
{
	int deviceCount;
	cudaGetDeviceCount(&deviceCount);
	return deviceCount;
}

cudaDeviceProp* CudaSupportImpl::getDeviceProperties(int device)
{
	if((device >= 0) && (device < getDeviceCount()))
		 return &CUDAProperties[device];
	return 0;
}


extern "C"
{
#if WIN32
__declspec(dllexport)
#endif
OPI::CudaSupport* createCudaSupport()
{
	return new CudaSupportImpl();
}
}
