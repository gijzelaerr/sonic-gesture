#ifndef _COMBINER_H
#define	_COMBINER_H


#include "cv.h"

using namespace cv;

class Combiner {
public:
    Combiner();
    Combiner(Size frame_size, int num_of_win_in_x);
    Mat render();
    void add_image(Mat & image);
    vector<Mat> images;
private:
    Mat combination, temp;
    
    Size frame_size;
    int num_of_win_in_x;
};


#endif	/* _COMBINER_H */

