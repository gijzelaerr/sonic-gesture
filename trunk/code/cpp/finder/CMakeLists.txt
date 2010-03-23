cmake_minimum_required(VERSION 2.8)
PROJECT( finder )
FIND_PACKAGE(OpenCV REQUIRED )
FIND_PACKAGE( Boost COMPONENTS filesystem system date_time REQUIRED )

add_executable (run src/run.cpp src/hand.cpp src/skin.cpp src/tools.cpp src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h src/settings.h src/limb.h)
target_link_libraries (run  ${OpenCV_LIBS})

add_executable (capture src/capture.cpp src/hand.cpp src/skin.cpp src/tools.cpp src/finder.cpp src/limb.cpp src/tools.h src/skin.h src/hand.h src/finder.h src/settings.h src/limb.h)
target_link_libraries (capture  ${OpenCV_LIBS})
target_link_libraries (capture  ${Boost_LIBRARIES})


add_executable (train src/train.cpp src/train.h src/hand.cpp src/skin.cpp src/tools.cpp)
target_link_libraries (train ${OpenCV_LIBS})
target_link_libraries (train ${Boost_LIBRARIES})
include_directories (${BOOST_FILESYSTEM_LIBRARY})

link_directories ( ${Boost_LIBRARY_DIRS} )
include_directories ( ${Boost_INCLUDE_DIRS} )

#TODO: add -D_GLIBCXX_PARALLEL if using openMP

