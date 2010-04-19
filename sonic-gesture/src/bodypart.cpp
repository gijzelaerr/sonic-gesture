
#include "bodypart.h"
#include "blob.h"


BodyPart::BodyPart() {    
    // hog settings
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();
};


BodyPart::~BodyPart() {};


void BodyPart::update(Blob blob, const Mat& image) {
    this->blob = blob;
    this->image = image;
    make_cutout();
    compute_hog();
};

void BodyPart::update(const Mat& image) {
    this->image = image;
    make_cutout();
    compute_hog();
};


void BodyPart::make_cutout() {
    mask = Mat(image.size(), CV_8U, Scalar(0));
    binary = Mat(image.size(), CV_8U, Scalar(0));
    vector<vector<Point> > contours;
    contours.push_back(blob.contour);
    drawContours( mask, contours, -1, Scalar(255), CV_FILLED);
    image.copyTo(binary, mask);
    Rect cutout_border = boundingRect(Mat(blob.contour));
    cutout = binary(cutout_border);
    resize(cutout, sized, Size(64,128));
    cvtColor(sized, hog_image, CV_BGR2GRAY);
    equalizeHist(hog_image, hog_image);
}


void BodyPart::compute_hog() {    
    hog.compute(hog_image, hog_features, winStride, padding, locations);
};


const Mat BodyPart::get_hog_image() {
    assert(hog_image.data);
    return hog_image;
};



BodyParts::BodyParts() {
};


BodyParts::~BodyParts() {
};


void BodyParts::update(const vector<vector<Point> >& contours, Point face_center, const Mat& image) {
    vector<Blob> blobs, tmp_blobs;
    Blob blob;
    int head_pos, left_pos, right_pos = -1;

    // first make blobs
    for (unsigned int i = 0; i < contours.size(); i++) {
        blobs.push_back(Blob(contours.at(i)));
    }    

    // sort the limbs on size
    sort(blobs.begin(), blobs.end(), compare_blob_size);
    
    // take only the 3 biggest blobs
    int s = MIN((int)blobs.size(), 3);
    for(int i=0; i < s; i++)
        tmp_blobs.push_back(blobs.at(i));
    blobs = tmp_blobs;
    
    // then sort the blobs for x pos, left to right
    sort(blobs.begin(), blobs.end(), compare_blob_xpos);
    
    for (unsigned int i = 0; i < blobs.size(); i++) {
        if (pointPolygonTest(Mat(blobs.at(i).contour), face_center, false) > 0) {
            head_pos = i;
            break;
        }
    }
    
    switch(blobs.size()) {
        case 3:
            switch (head_pos) {
                case 0:
                    left_pos = 1;
                    right_pos = 2;
                case 1:
                    left_pos = 0;
                    right_pos = 2;
                case 2:
                    left_pos = 0;
                    right_pos = 1;
                default:
                    left_pos = 0;
                    head_pos = 1;
                    right_pos = 2;
            }
        case 2:
            switch (head_pos) {
                case 0:
                    right_pos = 1;
                case 1:
                    left_pos = 0;
                default:
                    left_pos = 0;
                    right_pos = 1;
            }
        case 1:
            head_pos = 0;
        default:
            head_pos = right_pos = left_pos = -1;
    }
};