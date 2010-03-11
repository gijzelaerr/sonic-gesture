cmake_minimum_required(VERSION 2.8)
PROJECT( finder )
FIND_PACKAGE(OpenCV REQUIRED )
FIND_PACKAGE( Boost COMPONENTS filesystem REQUIRED )

add_executable (finder src/main.cpp src/hand.cpp src/skin.cpp src/tools.cpp src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h src/settings.h src/limb.h)
target_link_libraries (finder  ${OpenCV_LIBS})

add_executable (train src/train.cpp src/train.h)
target_link_libraries (train  ${OpenCV_LIBS})
target_link_libraries (train  ${Boost_LIBRARIES})

link_directories ( ${Boost_LIBRARY_DIRS} )
include_directories ( ${Boost_INCLUDE_DIRS} )

#TODO: add -D_GLIBCXX_PARALLEL if using openMP

