cmake_minimum_required(VERSION 2.8)
project( CameraControl )

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

find_package( GPHOTO2 REQUIRED )
find_package( LibJpeg REQUIRED )
#find_package( OpenCV REQUIRED )

SET(CameraControl_SOURCES cameraControl.cpp cameraControl.h)

ADD_LIBRARY(cameraControl SHARED ${CameraControl_SOURCES})
TARGET_LINK_LIBRARIES(cameraControl ${LIBGPHOTO2_LIBRARIES} ${LibJpeg_LIBRARIES}) #${OpenCV_LIBS})



