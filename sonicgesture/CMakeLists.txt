cmake_minimum_required(VERSION 2.8)

project( "sonic-gesture" )
find_package( OpenCV REQUIRED )  
find_package(Qt4 COMPONENTS QtCore QtGui REQUIRED )

include(${QT_USE_FILE})

# where can we find data
set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(DATA_DIR "./data" CACHE PATH "Where is the sonic gesture data")
message(DATA_DIR)
essage(STATUS "DATA_DIR: ${DATA_DIR}")
include_directories(${PROJECT_SOURCE_DIR})

#pass cmake config to source
configure_file ("${PROJECT_SOURCE_DIR}/cmake.h.in" "${PROJECT_BINARY_DIR}/src/cmake.h")

# include generated files
include_directories("${PROJECT_BINARY_DIR}/src")

#include generated QT files
include_directories(${PROJECT_BINARY_DIR})

#build 32 bit for OSX
set(CMAKE_OSX_ARCHITECTURES "i386")

###
### QT STUFF
###
qt4_wrap_cpp (SONICGESTURE_CPP src/qcvimage.h src/mainwindow.h src/application.h src/settingscreen.h)
qt4_wrap_ui (SONICGESTURE_UI qt/mainwindow.ui qt/settingscreen.ui)
qt4_add_resources (SONICGESTURE_RES qt/resources.qrc)

# all source files
set(SONICGESTURE_SOURCE src/qcvimage.cpp src/finder.cpp src/skinfinder.cpp
    src/source.cpp src/histogram.cpp src/combiner.cpp src/tools.cpp src/settings.cpp
    src/bodypart.cpp src/blob.cpp src/matcher.cpp src/loader.cpp src/main.cpp
    src/mainwindow.cpp src/capture.cpp src/application.cpp src/recorder.cpp
    src/settingscreen.cpp src/labeler.cpp src/audio.cpp)

###
### BUILD SONIC GESTURE
###
add_executable ( sonicgesture
    ${SONICGESTURE_SOURCE}
    ${SONICGESTURE_CPP}
    ${SONICGESTURE_RES}
    ${SONICGESTURE_UI}
)

target_link_libraries (sonicgesture
    ${OpenCV_LIBS}
    ${QT_LIBRARIES}
    lo
)

###
### BUILD EXTRACTOR
###
add_executable (extractor
    src/extractor.cpp
    src/settings.cpp
    src/source.cpp
    src/skinfinder.cpp
    src/bodypart.cpp
    src/tools.cpp
    src/histogram.cpp
    src/blob.cpp
    ${SONICGESTURE_RES}
)

target_link_libraries (extractor
    ${OpenCV_LIBS}
    ${QT_LIBRARIES}
)

###
### BUILD PERFORMANCE
###
add_executable (performance
    src/performance.cpp
    src/settings.cpp
    src/source.cpp
    src/skinfinder.cpp
    src/bodypart.cpp
    src/tools.cpp
    src/histogram.cpp
    src/blob.cpp
    src/matcher.cpp
    src/loader.cpp
    ${SONICGESTURE_RES}
)

target_link_libraries (performance
    ${OpenCV_LIBS}
    ${QT_LIBRARIES}
)

###
### BUILD DUMPER
###
add_executable (dumper
    src/dumpFeatures.cpp
    src/settings.cpp
    src/tools.cpp
    src/loader.cpp
    ${SONICGESTURE_RES}
)

target_link_libraries (dumper
    ${OpenCV_LIBS}
    ${QT_LIBRARIES}
)




###
### INSTALLATION STUFF
###
SET(CPACK_PACKAGE_NAME "sonicgesture")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Sonic Gesture")
SET(CPACK_PACKAGE_DESCRIPTION "Sonic Gesture - translating sound into gestures")
SET(CPACK_PACKAGE_VENDOR "Gijs Molenaar")
SET(CPACK_PACKAGE_CONTACT "Gijs Molenaar <gijsmolenaar@gmail.com>")

SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYRIGHT.txt")
SET(CPACK_PACKAGE_EXECUTABLES "sonicgesture;SonicGesture")
SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/data/installer/icon.bmp")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "1")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

# the same for all architechtures
install (TARGETS sonicgesture DESTINATION bin)

IF(WIN32)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/sets" DESTINATION data PATTERN ".svn" EXCLUDE)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/storage" DESTINATION data PATTERN ".svn" EXCLUDE)

    set(CPACK_GENERATOR "NSIS")
    # include required windows DLL's
	file(GLOB OPENCV_LIBS "${OpenCV_DIR}/bin/*.dll")
    INSTALL(FILES
        ${OPENCV_LIBS}
        DESTINATION bin
    )
ENDIF(WIN32)

IF(UNIX AND NOT APPLE)
    install (TARGETS sonicgesture DESTINATION bin)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/sets" DESTINATION share/${CPACK_PACKAGE_NAME} PATTERN ".svn" EXCLUDE)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/storage" DESTINATION share/${CPACK_PACKAGE_NAME} PATTERN ".svn" EXCLUDE)

    # only use this when building package!

    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libopencv0, liblo7, libqt4-gui, libqt4-core")
ENDIF(UNIX AND NOT APPLE)

IF(APPLE)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/sets" DESTINATION share/${CPACK_PACKAGE_NAME} PATTERN ".svn" EXCLUDE)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/storage" DESTINATION share/${CPACK_PACKAGE_NAME} PATTERN ".svn" EXCLUDE)

    set(CPACK_GENERATOR "Bundle")
    set(CPACK_BUNDLE_NAME "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
    set(CPACK_BUNDLE_PLIST "${CMAKE_SOURCE_DIR}/Info.plist")
    set(CPACK_BUNDLE_ICON "${CPACK_PACKAGE_ICON}")
ENDIF(APPLE)

INCLUDE(CPack)
