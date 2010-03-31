cmake_minimum_required(VERSION 2.8)

project( "sonic-gesture" )
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

#set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")
set(DATA_DIR "../data")

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
#install (TARGETS train DESTINATION bin)
install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/examples" DESTINATION data PATTERN ".svn" EXCLUDE)
install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/haar" DESTINATION data PATTERN ".svn" EXCLUDE)
install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/hand" DESTINATION data PATTERN ".svn" EXCLUDE)

# include required windows DLL's
IF(WIN32)
	file(GLOB OPENCV_LIBS "${OpenCV_DIR}/bin/*.dll")
	file(GLOB BOOST_FILESYSTEM_LIBS "${BOOST_ROOT}/lib/boost_filesystem-vc90-mt-*.dll")
	file(GLOB BOOST_DATETIME_LIBS "${BOOST_ROOT}/lib/boost_date_time-vc90-mt-*.dll")
	file(GLOB BOOST_SYSTEM_LIBS "${BOOST_ROOT}/lib/boost_system-vc90-mt-*.dll")
    INSTALL(FILES
        ${OPENCV_LIBS}
		${BOOST_DATETIME_LIBS}
		${BOOST_FILESYSTEM_LIBS}
		${BOOST_SYSTEM_LIBS}
        DESTINATION bin
    )
ENDIF(WIN32)

INCLUDE(CPack)
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Sonic Gesture")
SET(CPACK_PACKAGE_VENDOR "Gijs Molenaar")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYRIGHT.txt")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Translation gestures into sound")
SET(CPACK_PACKAGE_EXECUTABLES "run;Run capture;Capture")
SET(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/data/installer/icon.bmp")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "1")


