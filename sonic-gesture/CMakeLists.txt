cmake_minimum_required(VERSION 2.8)

enable_testing(true)

project( "sonic-gesture" )
find_package( OpenCV REQUIRED )  
find_package(Qt4 COMPONENTS QtCore QtGui REQUIRED )

include(${QT_USE_FILE})

# where can we find data
set(PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/data")

#pass cmake config to source
configure_file (
  "${PROJECT_SOURCE_DIR}/cmake.h.in"
  "${PROJECT_BINARY_DIR}/cmake.h"
  )

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})

QT4_WRAP_CPP(SONICGESTURE_CPP src/qcvimage.h src/mainwindow.h src/application.h)
QT4_WRAP_UI(SONICGESTURE_UI qt/mainwindow.ui)
QT4_ADD_RESOURCES(SONICGESTURE_RES qt/resources.qrc)

add_executable (sonicgesture src/qcvimage.cpp src/finder.cpp src/skinfinder.cpp src/source.cpp src/histogram.cpp src/combiner.cpp src/tools.cpp src/settings.h src/settings.cpp src/skinfinder.h src/source.h src/histogram.h src/combiner.h src/tools.h src/bodypart.cpp src/bodypart.h src/blob.cpp src/blob.h src/matcher.cpp src/matcher.h src/loader.cpp src/loader.h src/main.cpp src/mainwindow.cpp src/mainwindow.h src/qcvimage.h src/capture.cpp src/capture.h src/application.cpp src/application.h src/recorder.cpp src/recorder.h ${SONICGESTURE_CPP} ${SONICGESTURE_RES} ${SONICGESTURE_UI})

target_link_libraries (sonicgesture ${OpenCV_LIBS})
target_link_libraries(sonicgesture ${QT_LIBRARIES})

# what to install where
install (TARGETS sonicgesture DESTINATION bin)
#install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/examples" DESTINATION data PATTERN ".svn" EXCLUDE)
#install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/haar" DESTINATION data PATTERN ".svn" EXCLUDE)
#install (DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/data/hand" DESTINATION data PATTERN ".svn" EXCLUDE)

# include required windows DLL's
IF(WIN32)
	file(GLOB OPENCV_LIBS "${OpenCV_DIR}/bin/*.dll")
    INSTALL(FILES
        ${OPENCV_LIBS}
        DESTINATION bin
    )
ENDIF(WIN32)

INCLUDE(CPack)
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Sonic Gesture")
SET(CPACK_PACKAGE_VENDOR "Gijs Molenaar")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYRIGHT.txt")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Translation gestures into sound")
SET(CPACK_PACKAGE_EXECUTABLES "sonicgesture;SonicGesture")
SET(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/data/installer/icon.bmp")
SET(CPACK_PACKAGE_VERSION_MAJOR "0")
SET(CPACK_PACKAGE_VERSION_MINOR "0")
SET(CPACK_PACKAGE_VERSION_PATCH "1")

