#include <iostream>

#include <cstdio>
#include <cstring>
#include <cstdlib>

#include <gphoto2/gphoto2-camera.h>
#include <jpeglib.h>

#include "opencv2/core/core.hpp"                 /* Opencv libraries */
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
//#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/features2d/features2d.hpp"

#include "cameraControl.h"

CameraFile* cfile;
Camera *camera;
GPContext *context;
CameraFilePath cameraFilePath;
unsigned long bmp_size;
unsigned char *bmp_buffer = NULL;
int width, height;

///  Callbacks for camera error management
void error_func(GPContext *context, const char *str, char*, void *data)
{
  fprintf(stderr, "*** Contexterror ***\n");
  fprintf(stderr, "%s", str);
  fprintf(stderr, "\n");
}

void message_func(GPContext *context, const char *str, char*, void *data)
{
  printf("%s", str);
  printf("\n");
}


bool Initialize()
{
  context = gp_context_new();
  /* set callbacks for camera messages */
  gp_context_set_error_func(context, error_func, NULL);
  gp_context_set_message_func(context, message_func, NULL);

  gp_camera_new (&camera);

  /* This call will autodetect cameras, take the first one from the list and use it */
  int ret = gp_camera_init(camera, context);
  if (ret != GP_OK)
  {
    gp_camera_free(camera);
    return false;
  }

  gp_file_new(&cfile);

  // take a shot to assure that the camera is open
  ret = gp_camera_capture(camera, GP_CAPTURE_IMAGE, &cameraFilePath, context);

  // Set the configuration of the camera
  CameraWidget *widget_main,
               *widget_capturesettings,
               *widget_zoom,
               *widget_shootingmode,
               *widget_imgsettings,
               *widget_white_balance,
               *widget_image_size,
               *widget_iso;

  float zoom = 8;
  const char* iso = "400";
  const char* shootingmode =  "Manual";
  const char* whitebalance =  "Fluorescent";
  const char* imagesize = "medium 3";

  /* Get the first level of parameters of the camera */
  gp_camera_get_config(camera, &widget_main, context);

  /* For the CANON A640, the organisation of parameters is the following :

   /main/capturesettings/zoom
   /main/capturesettings/shootingmode
   /main/imgsettings/whitebalance
   /main/imgsettings/imagesize

   So widget_main corresponds to main.*/

  /* Set the zoom and the shooting mode */
  gp_widget_get_child_by_name(widget_main, "capturesettings", &widget_capturesettings);

  gp_widget_get_child_by_name(widget_capturesettings, "zoom", &widget_zoom);
  gp_widget_set_value(widget_zoom, &zoom);
  gp_camera_set_config(camera, widget_main, context);

  gp_widget_get_child_by_name(widget_capturesettings, "shootingmode", &widget_shootingmode);
  gp_widget_set_value(widget_shootingmode, shootingmode);
  gp_camera_set_config(camera, widget_main, context);

  /* Set the white balance and the image size */
  gp_widget_get_child_by_name(widget_main, "imgsettings", &widget_imgsettings);

  gp_widget_get_child_by_name(widget_imgsettings, "whitebalance", &widget_white_balance);
  gp_widget_set_value(widget_white_balance, whitebalance);
  gp_camera_set_config(camera, widget_main, context);

  gp_widget_get_child_by_name(widget_imgsettings, "imagesize", &widget_image_size);
  gp_widget_set_value(widget_image_size, imagesize);
  gp_camera_set_config(camera, widget_main, context);

  gp_widget_get_child_by_name(widget_imgsettings, "iso", &widget_iso);
  gp_widget_set_value(widget_iso, iso);
  gp_camera_set_config(camera, widget_main, context);


  /* Update these parameters in the camera */
  gp_camera_set_config(camera, widget_main, context);

  return true;
}

void Finalize()
{
  gp_camera_unref(camera);
  gp_context_unref(context);
}

bool CapturePreview()
{
  //gp_camera_capture(camera, GP_CAPTURE_IMAGE, &cameraFilePath, context);
  int ret = gp_camera_capture_preview(camera, cfile, context);

  // Variables for the source jpg
  unsigned long jpg_size;
  unsigned char *jpg_buffer;

  const char* data;
  gp_file_get_data_and_size (cfile, &data, &jpg_size);
  return jpg2bmp(ret,jpg_size,jpg_buffer,data);
}

bool CaptureImage()
{
    int ret = gp_camera_capture(camera, GP_CAPTURE_IMAGE, &cameraFilePath, context);

    // Variables for the source jpg
    unsigned long jpg_size;
    unsigned char *jpg_buffer;

    const char* data;

    gp_camera_file_get(camera, cameraFilePath.folder, cameraFilePath.name,
                 GP_FILE_TYPE_NORMAL, cfile, context);

    gp_file_get_data_and_size(cfile, &data, &jpg_size);


    return jpg2bmp(ret,jpg_size,jpg_buffer,data);
}

bool jpg2bmp(int ret,unsigned long jpg_size,unsigned char *jpg_buffer,const char* data)
{


  jpg_buffer = (unsigned char*)malloc(jpg_size);
  memcpy(jpg_buffer, data, jpg_size);

  // Variables for the decompressor itself
  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;

  // Variables for the output buffer, and how long each row is
  int row_stride, pixel_size;

  // Allocate a new decompress struct, with the default error handler.
  // The default error handler will exit() on pretty much any issue,
  // so it's likely you'll want to replace it or supplement it with
  // your own.
  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);


  // Configure this decompressor to read its data from a memory
  // buffer starting at unsigned char *jpg_buffer, which is jpg_size
  // long, and which must contain a complete jpg already.
  //
  // If you need something fancier than this, you must write your
  // own data source manager, which shouldn't be too hard if you know
  // what it is you need it to do. See jpeg-8d/jdatasrc.c for the
  // implementation of the standard jpeg_mem_src and jpeg_stdio_src
  // managers as examples to work from.
  jpeg_mem_src(&cinfo, jpg_buffer, jpg_size);


  // Have the decompressor scan the jpeg header. This won't populate
  // the cinfo struct output fields, but will indicate if the
  // jpeg is valid.
  int rc = jpeg_read_header(&cinfo, TRUE);
  if (rc != 1) {
      std::cerr << "File does not seem to be a normal JPEG";
      return false;
  }

  // By calling jpeg_start_decompress, you populate cinfo
  // and can then allocate your output bitmap buffers for
  // each scanline.
  jpeg_start_decompress(&cinfo);

  width = cinfo.output_width;
  height = cinfo.output_height;
  pixel_size = cinfo.output_components;

  bmp_size = width * height * pixel_size;
  bmp_buffer = (unsigned char*) malloc(bmp_size);

  // The row_stride is the total number of bytes it takes to store an
  // entire scanline (row).
  row_stride = width * pixel_size;

  //
  // Now that you have the decompressor entirely configured, it's time
  // to read out all of the scanlines of the jpeg.
  //
  // By default, scanlines will come out in RGBRGBRGB...  order,
  // but this can be changed by setting cinfo.out_color_space
  //
  // jpeg_read_scanlines takes an array of buffers, one for each scanline.
  // Even if you give it a complete set of buffers for the whole image,
  // it will only ever decompress a few lines at a time. For best
  // performance, you should pass it an array with cinfo.rec_outbuf_height
  // scanline buffers. rec_outbuf_height is typically 1, 2, or 4, and
  // at the default high quality decompression setting is always 1.
  while (cinfo.output_scanline < cinfo.output_height) {
    unsigned char *buffer_array[1];
    buffer_array[0] = bmp_buffer + (cinfo.output_scanline) * row_stride;

    jpeg_read_scanlines(&cinfo, buffer_array, 1);
  }

  // Once done reading *all* scanlines, release all internal buffers,
  // etc by calling jpeg_finish_decompress. This lets you go back and
  // reuse the same cinfo object with the same settings, if you
  // want to decompress several jpegs in a row.
  //
  // If you didn't read all the scanlines, but want to stop early,
  // you instead need to call jpeg_abort_decompress(&cinfo)
  jpeg_finish_decompress(&cinfo);

  // At this point, optionally go back and either load a new jpg into
  // the jpg_buffer, or define a new jpeg_mem_src, and then start
  // another decompress operation.

  // Once you're really really done, destroy the object to free everything
  jpeg_destroy_decompress(&cinfo);
  // And free the input buffer
  free(jpg_buffer);

  return ret == GP_OK;
}

unsigned long int GetPreviewSize()
{ 
  return bmp_size;
}

bool GetPreviewData(unsigned char* data, unsigned long int size,  int* w, int* h)
{
  if (NULL == bmp_buffer)
    return false;

  memcpy(data, bmp_buffer, size);
  free(bmp_buffer);
  bmp_buffer = NULL;

  *w = width;
  *h = height;

  return true;
}
