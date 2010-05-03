#include <iostream>

#include "cv.h"
#include "highgui.h"
#include "settings.h"

using namespace cv;
using namespace std;

void draw_num(int num, Mat image) {
    std::string s;
    std::stringstream out;
    out.precision(1);
    out << std::fixed << num;
    s = out.str();
    putText(image, s, Point(5, 12), FONT_HERSHEY_SIMPLEX, 0.4, Scalar(255, 255, 255), 1);
}

int main (int argc, char * const argv[]) {
    VideoCapture cap = VideoCapture(DEVICE);
    
    CascadeClassifier clasfr = CascadeClassifier(FACEHAAR);
    Mat frame, small, measurement;
    vector<Rect> faces;
    Rect face;
    
    // kalman stuff
    KalmanFilter kalman = KalmanFilter();
    const int stateparms = 2;
    const int measureparms = 1;
    
    float f[stateparms][stateparms] = {
        {1, 1},
        {0, 1}
    };
    Mat transition = Mat(stateparms, stateparms, CV_32FC1, f);
    
    kalman.init(stateparms, measureparms); 
    kalman.transitionMatrix = transition;   
    
    for(;;) {
        cap >> frame;
        resize(frame, small, Size(320, 240));
        clasfr.detectMultiScale(small, faces, 1.3);
  
        Mat y_k = kalman.predict();   
        draw_num(y_k.at<float>(0, 0), small);
        if (faces.size() > 0) {
            face = faces.at(0);
            float m[1][measureparms] = {{face.x}};
            measurement = Mat(1, measureparms, CV_32FC1, m).t();
            kalman.correct(measurement);
            rectangle(small, face.tl(), face.br(), Scalar(0, 255, 0));
        }
        imshow("cap", small);
        
        if (waitKey(4) > 0)
            break;
    };

    return 0;
}
