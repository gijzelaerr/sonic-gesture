cmake_minimum_required(VERSION 2.8)

project( "sonic-gesture" )
find_package( OpenCV REQUIRED )
find_package(Qt4 COMPONENTS QtCore QtGui REQUIRED )

include(${QT_USE_FILE})

# where can we find data
set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(DATA_DIR "." CACHE PATH "where is the sonic gesture data")
message(STATUS "DATA_DIR: ${DATA_DIR}")
include_directories(${PROJECT_SOURCE_DIR})

#pass cmake config to source
configure_file ("${PROJECT_SOURCE_DIR}/cmake.h.in" "${PROJECT_BINARY_DIR}/src/cmake.h")

# include generated files
include_directories("${PROJECT_BINARY_DIR}/src")

#include generated QT files
include_directories(${PROJECT_BINARY_DIR})

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
    src/mainwindow.cpp src/application.cpp src/recorder.cpp
    src/settingscreen.cpp src/labeler.cpp src/audio.cpp)

###
### BUILD SONIC GESTURE
###
IF(APPLE)
    add_executable ( sonicgesture MACOSX_BUNDLE
        ${SONICGESTURE_SOURCE}
        ${SONICGESTURE_CPP}
        ${SONICGESTURE_RES}
        ${SONICGESTURE_UI}
    )
ELSE()
    add_executable ( sonicgesture
        ${SONICGESTURE_SOURCE}
        ${SONICGESTURE_CPP}
        ${SONICGESTURE_RES}
        ${SONICGESTURE_UI}
    )
ENDIF()

target_link_libraries (sonicgesture
    ${OpenCV_LIBS}
    ${QT_LIBRARIES}
    lo
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
SET(CPACK_PACKAGE_VERSION_MAJOR "1")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
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

    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libcv2.1, libhighgui2.1, libcvaux2.1, liblo7, libqt4-gui, libqt4-core")
ENDIF(UNIX AND NOT APPLE)

IF (APPLE)
    INSTALL(TARGETS sonicgesture BUNDLE DESTINATION . COMPONENT Runtime)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/sets" DESTINATION ${CMAKE_INSTALL_PREFIX}/Contents/Resources PATTERN ".svn" EXCLUDE)
    install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/storage" DESTINATION ${CMAKE_INSTALL_PREFIX}/Contents/Resources PATTERN ".svn" EXCLUDE)

    INSTALL(CODE "
            include(BundleUtilities)
            SET(BU_CHMOD_BUNDLE_ITEMS ON)
            fixup_bundle(\"\${CMAKE_INSTALL_PREFIX}/emovision.app\" \"\${QTPLUGINS}\")
            " COMPONENT Runtime)

    SET(MACOSX_BUNDLE_BUNDLE_NAME "sonic gesture")
    SET(MACOSX_BUNDLE_INFO_STRING "SonicGesture "${VERSION})
    SET(MACOSX_BUNDLE_GUI_IDENTIFIER "com.gijzelaerr.sonicgesture" )
    SET(MACOSX_BUNDLE_BUNDLE_VERSION ${VERSION})
    SET(MACOSX_BUNDLE_LONG_VERSION_STRING ${VERSION})
    SET(CPACK_GENERATOR "DragNDrop")
ENDIF(APPLE)

INCLUDE(CPack)
