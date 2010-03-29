
#include <exception>
#include <iostream>

#include "opencv/cv.h"
#include "opencv/highgui.h"

#include "settings.h"
#include "skin.h"
#include "tools.h"

using namespace cv;
using namespace std;




Skin::Skin(const string& facefile, const string& haarfile) {
    load_image(facefile);
    load_haar(haarfile);
    find_face();
    make_histogram();
}

void Skin::load_image(const string& filename) {
    img = imread(filename, 1);
    if (!img.data) {
		cout << "can't load" << filename << endl;
        throw exception();
	}
    cvtColor(img, hsv, CV_BGR2HSV);
    cvtColor(img, bw, CV_BGR2GRAY);
};

void Skin::load_haar(const string& filename) {
	if ( !haarzoeker.load(FACEHAAR) ) {
		cerr << "can't load" << filename << endl;
		throw exception();
    }
}

void Skin::find_face() {
    haarzoeker.detectMultiScale(img, faces, 1.1, 5, CV_HAAR_SCALE_IMAGE, Size(30, 30) );
	if (faces.size() == 0) {
		cerr << "no faces found in image" << endl;
		throw exception();
	}
	face_rect = faces.at(0);
    sub_rect = sub_region(face_rect);
    facepixels = hsv(sub_rect);
}

void Skin::make_histogram() {
    int hbins = 30, sbins = 32;
    int histSize[] = {hbins, sbins};
    const float hranges[] = { 0, 180 };
    const float sranges[] = { 0, 256 };
    const float* ranges[] = { hranges, sranges };
    int channels[] = {0, 1};
    calcHist( &facepixels,  1, channels, Mat(), histogram, 2,  histSize, ranges );
}

