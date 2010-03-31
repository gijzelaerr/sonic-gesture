cmake_minimum_required(VERSION 2.8)

project( "sonic-gesture" )

INCLUDE(CPack)
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Sonic Gesture")
SET(CPACK_PACKAGE_VENDOR "Gijs Molenaar http://gijs.pythonic.nl")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYRIGHT.txt")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "1")

find_package( OpenCV REQUIRED )  
find_package( Boost COMPONENTS filesystem system date_time REQUIRED )

## if using OpenMP:
#ADD_DEFINITIONS("-D_GLIBCXX_PARALLEL")

# OpenCV doesn't compile 64 bit on mac
if(${APPLE})
    set(CMAKE_OSX_ARCHITECTURES "i386")
endif()

# where can we find data
set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")

#pass cmake config to source
configure_file (
  "${PROJECT_SOURCE_DIR}/settings.h.in"
  "${PROJECT_BINARY_DIR}/settings.h"
  )

include_directories(${PROJECT_BINARY_DIR})
include_directories(${Boost_INCLUDE_DIRS})

add_executable (run src/run.cpp src/hand.cpp src/skin.cpp src/tools.cpp
    src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h
    src/limb.h src/common.h)
target_link_libraries (run  ${OpenCV_LIBS})

add_executable (capture src/capture.cpp src/hand.cpp src/skin.cpp src/tools.cpp
    src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h
    src/limb.h src/settings.h.in src/common.h)
target_link_libraries(capture ${OpenCV_LIBS} ${Boost_LIBRARIES})

add_executable (train src/train.cpp src/train.h src/hand.cpp src/skin.cpp
    src/tools.cpp src/common.h)
target_link_libraries(train ${OpenCV_LIBS} ${Boost_LIBRARIES})

# what to install where
install (TARGETS run DESTINATION bin)
install (TARGETS capture DESTINATION bin)
install (TARGETS train DESTINATION bin)
install (DIRECTORY "${DATA_DIR}" DESTINATION . PATTERN ".svn" EXCLUDE)

