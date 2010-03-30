cmake_minimum_required(VERSION 2.8)
project( finder )
find_package( OpenCV REQUIRED )  
find_package( Boost COMPONENTS filesystem system date_time REQUIRED )

## if using OpenMP:
#ADD_DEFINITIONS("-D_GLIBCXX_PARALLEL")

if(${APPLE})
    set(CMAKE_OSX_ARCHITECTURES "i386")
endif()

set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../data")

configure_file (
  "${PROJECT_SOURCE_DIR}/settings.h.in"
  "${PROJECT_BINARY_DIR}/settings.h"
  )

include_directories(${PROJECT_BINARY_DIR})
include_directories(${Boost_INCLUDE_DIRS})

add_executable (run src/run.cpp src/hand.cpp src/skin.cpp src/tools.cpp
    src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h
    src/limb.h)
target_link_libraries (run  ${OpenCV_LIBS})

add_executable (capture src/capture.cpp src/hand.cpp src/skin.cpp src/tools.cpp
    src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h
    src/limb.h src/settings.h.in)
target_link_libraries(capture ${OpenCV_LIBS} ${Boost_LIBRARIES})

add_executable (train src/train.cpp src/train.h src/hand.cpp src/skin.cpp
    src/tools.cpp)
target_link_libraries(train ${OpenCV_LIBS} ${Boost_LIBRARIES})



