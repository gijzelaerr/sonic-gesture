cmake_minimum_required(VERSION 2.8)
PROJECT( finder )
FIND_PACKAGE(OpenCV REQUIRED )
FIND_PACKAGE( boost COMPONENTS filesystem REQUIRED )

add_executable (finder main.cpp hand.cpp skin.cpp tools.cpp finder.cpp limb.cpp tools.h skin.h hand.h finder.h settings.h limb.h)
target_link_libraries (finder  ${OpenCV_LIBS})

add_executable (train train.cpp train.h)
target_link_libraries (train  ${OpenCV_LIBS})
target_link_libraries (train  ${Boost_LIBRARIES})

link_directories ( ${Boost_LIBRARY_DIRS} )
include_directories ( ${Boost_INCLUDE_DIRS} )

#TODO: add -D_GLIBCXX_PARALLEL if using openMP

