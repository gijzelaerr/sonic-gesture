
#include "cv.h"


#include "settings.h"
#include "source.h"
#include "skinfinder.h"
#include "bodypart.h"
#include <iostream>

using namespace cv;
using namespace std;

Mat size_rounder(Mat image, int target) {
    int w = round(double(image.cols) / target) * target;
    int h = round(double(image.rows) / target) * target;
    Mat result;
    resize(image, result, Size(w,h));
    return result;

}
int main(int, char**) {
    SkinFinder skinFinder = SkinFinder();
    BodyParts bodyParts = BodyParts();
    Mat good = imread(DATA_DIR + "/good.jpg");
    Mat occlusion = imread(DATA_DIR + "/occlusion.jpg");
    vector<vector<Point> > skins = skinFinder.compute(good);
    bodyParts.update(skins, skinFinder.face_center, good);
    Mat visuals = bodyParts.draw_in_image();
    //HOGDescriptor() : winSize(64,128), blockSize(16,16), blockStride(8,8), cellSize(8,8), nbins(9)

    int t = 8;
    Mat sized = size_rounder(bodyParts.left_hand.hog_image, t);
    HOGDescriptor hog = HOGDescriptor(sized.size(), Size(t*2,t*2), Size(t,t), Size(t,t), 9);

    //HOGDescriptor hog = HOGDescriptor();
    vector<float> hog_features;
    hog.compute(sized, hog_features);
    hog.setSVMDetector(hog_features);
    
    vector<Point> found_points;
    vector<Rect> found_rects;
    hog.detect(occlusion, found_points, 51.0, Size(t,t));
    hog.detectMultiScale(occlusion, found_rects, 51.0, Size(t,t));

    Point f;
    for (unsigned int i=0; i < found_points.size(); i++) {
        f = found_points.at(i);
        circle(occlusion, f, t, Scalar(0, 0, 255));
    }

    Rect r;
    for (unsigned int i=0; i < found_rects.size(); i++) {
        r = found_rects.at(i);
        rectangle(occlusion, r, Scalar(255, 0, 255));
    }

    for (;;) {
        imshow("good", visuals);
        imshow("occlusion", occlusion);
        if (waitKey(0)>0)
            return EXIT_SUCCESS;
    }
}
