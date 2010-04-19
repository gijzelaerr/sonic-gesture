
#include "bodypart.h"
#include "blob.h"
#include "settings.h"


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
    //make_cutout();
    //compute_hog();
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
    this->image = image;
    Blob blob;
    int head_pos = -1;
    int left_pos = -1;
    int right_pos = -1;

    // first make blobs
    for (unsigned int i = 0; i < contours.size(); i++) {
        blobs.push_back(Blob(contours.at(i), INFLATE_SIZE));
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
                    break;
                case 1:
                    left_pos = 0;
                    right_pos = 2;
                    break;
                case 2:
                    left_pos = 0;
                    right_pos = 1;
                    break;
                default:
                    left_pos = 0;
                    head_pos = 1;
                    right_pos = 2;
                    break;
            }
            break;
        case 2:
            switch (head_pos) {
                case 0:
                    right_pos = 1;
                    break;
                case 1:
                    left_pos = 0;
                    break;
                default:
                    left_pos = 0;
                    right_pos = 1;
                    break;
            }
            break;
        case 1:
            head_pos = 0;
            break;
        default:
            head_pos = right_pos = left_pos = -1;
            break;
    }
    
    if (head_pos > -1)
        head.update(blobs.at(head_pos), image);
    else
        head.update(image);

    if (left_pos > -1)
        left_hand.update(blobs.at(left_pos), image);
    else
        left_hand.update(image);
    
    if (right_pos > -1)
        right_hand.update(blobs.at(right_pos), image);
    else
        right_hand.update(image);
};

Mat BodyParts::draw_in_image() {
    Mat visuals;
    this->image.copyTo(visuals);
    convertScaleAbs(visuals, visuals, 0.2);

    
    if (head.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(head.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 0, 255 ));
    }
    
    if (left_hand.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(left_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 255, 0 ));
    }
    
    if (right_hand.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(right_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 255, 0, 0 ));
    }
    return visuals;
};