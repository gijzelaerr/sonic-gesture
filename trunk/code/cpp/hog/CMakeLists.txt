FIND_PACKAGE(OpenCV REQUIRED )
add_library(HogFinder part1.cpp part2.cpp part3.cpp)
target_link_libraries (HogFinder ${OpenCV_LIBS})

