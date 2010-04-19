cmake_minimum_required(VERSION 2.8)

enable_testing(true)

project( "sonic-gesture" )
find_package( OpenCV REQUIRED )  
find_package( Boost COMPONENTS filesystem system date_time REQUIRED )

#find_package(GTest REQUIRED)

# OpenCV 2.0 doesn't compile 64 bit on mac
#IF(${APPLE} )#AND ${OpenCV_VERSION_MAJOR} EQUAL 2 AND ${OpenCV_VERSION_MINOR} EQUAL 0)
#    set(CMAKE_OSX_ARCHITECTURES "i386")
#endif()

# where can we find data
set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")
#set(DATA_DIR "data")

#pass cmake config to source
configure_file (
  "${PROJECT_SOURCE_DIR}/cmake.h.in"
  "${PROJECT_BINARY_DIR}/cmake.h"
  )

include_directories(${PROJECT_BINARY_DIR})
include_directories(${Boost_INCLUDE_DIRS})
#include_directories(${GTEST_INCLUDE_DIRS})
#include_directories(${PROJECT_SOURCE_DIR})

#add_executable (run run finder limb tools histogram matcher stabilizer)
add_executable (run src/run.cpp src/videopipe.cpp src/skinfinder.cpp src/source.cpp src/histogram.cpp src/combiner.cpp src/tools.cpp src/tools.cpp src/limb.cpp src/settings.h src/videopipe.h src/skinfinder.h src/source.h src/histogram.h src/combiner.h src/tools.h src/tools.h src/limb.h src/bodypart.cpp src/bodypart.h src/blob.cpp src/blob.h )

target_link_libraries (run  ${OpenCV_LIBS})
target_link_libraries(run ${Boost_LIBRARIES})

#add_test(AllTestsInRun run_test)
#target_link_libraries(run ${GTEST_BOTH_LIBRARIES})
#add_executable(run_test  test/stabilizer_unittest.cpp)
#target_link_libraries(run_test ${GTEST_BOTH_LIBRARIES})

#add_executable (capture capture 
    #src/finder.cpp src/limb.cpp src/tools.h src/finder.h
    #src/limb.h src/settings.h src/common.h src/matcher.cpp src/matcher.h
    #src/stabilizer.h src/stabilizer.cpp src/histogram.cpp src/histogram.h)
#target_link_libraries (capture  ${OpenCV_LIBS})
#target_link_libraries(capture ${Boost_LIBRARIES})
#target_link_libraries(capture ${GTEST_BOTH_LIBRARIES})


# what to install where
install (TARGETS run DESTINATION bin)
#install (TARGETS capture DESTINATION bin)
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
#SET(CPACK_PACKAGE_EXECUTABLES "run;Run capture;Capture")
SET(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/data/installer/icon.bmp")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "1")

