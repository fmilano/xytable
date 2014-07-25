#ifndef CAMERA_CONTROL_H_INCLUDED
#define CAMERA_CONTROL_H_INCLUDED

extern "C" bool Initialize();
extern "C" void Finalize();
extern "C" bool CapturePreview();
extern "C" bool CaptureImage();
extern "C" bool jpg2bmp(int ret,unsigned long jpg_size,unsigned char *jpg_buffer,const char* data);
extern "C" unsigned long int GetPreviewSize();
extern "C" bool GetPreviewData(unsigned char* data, unsigned long int size, int* width, int* height);

#endif // CAMERA_CONTROL_H_INCLUDED
