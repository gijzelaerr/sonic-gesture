
#include <iostream>
#include "combiner.h"



Combiner::Combiner(const Size& frame_size, int num_of_win_in_x) {
    this->frame_size = frame_size;
    this->num_of_win_in_x = num_of_win_in_x;
    }

void Combiner::add_image(Mat& image) {
    this->images.push_back(&image);
}

Mat Combiner::render() {
    int xoffset, yoffset;
    Mat current;

    int width = MIN(num_of_win_in_x, (int)images.size())*frame_size.width;
    int height = int(ceil(float(images.size())/num_of_win_in_x)*frame_size.height);

    Size size = Size(width, height);
    combination = Mat(size, CV_8UC3, Scalar(0));

    
    for(unsigned int i=0; i < images.size(); i++) {
        current = *images.at(i);
        assert(current.data);

        if (current.size() != frame_size) {
            assert(frame_size.height>0);
            assert(frame_size.width>0);
            resize(current, temp, frame_size);
            current = temp;
        }
        xoffset = (i % num_of_win_in_x) * frame_size.width;
        yoffset = (i / num_of_win_in_x) * frame_size.height;

        Mat roi(combination, Rect(xoffset, yoffset, frame_size.width, frame_size.height));
        if (current.channels() == 3) {
            current.copyTo(roi);
        } else {
            cvtColor(current, roi, CV_GRAY2RGB);
        }
    }
    return combination;
}