
#include "common.h"
#include "limb.h"
#include "tools.h"


Limb::Limb() {
    center = Point();
    radius = 0;
    data = false;
};

Limb::Limb(vector<Point> contour, const Mat& image) {
    Mat binary;
    this->contour = contour;
    //this->contour = inflate_contour(this->contour, INFLATE_SIZE);
    data = true;
    minEnclosingCircle(Mat(contour), center, radius);
    
    Mat mask = Mat(image.size(), CV_8U, Scalar(0));
    binary = Mat(image.size(), CV_8U, Scalar(0));
   
    vector<vector<Point> > contours;
    contours.push_back(contour);
    drawContours( mask, contours, -1, Scalar(255), CV_FILLED);
    
    image.copyTo(binary, mask);

    Rect cutout_border = boundingRect(Mat(contour));

    //cutout_border = rect_in_mat(cutout_border, binary);
    cutout = binary(cutout_border); 
  
    Mat sized;
    resize(cutout, sized, Size(64,128));
    cvtColor(sized, bw, CV_BGR2GRAY);
    equalizeHist(bw, bw);

    compute_hog();
};


// compute hog of sub
void Limb::compute_hog() {
    
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    hog = HOGDescriptor();
    hog.compute(bw, hog_descriptors, winStride, padding, locations);
};


Mat Limb::get_limb_image() {
    assert(bw.data);
    return bw;
}


bool compare_limbs(const Limb& a, const Limb& b) {
    return a.radius > b.radius;
}


bool compare_limbs_xpos(const Limb& a, const Limb& b) {
    return a.center.x < b.center.x;
}

Limbs::Limbs(Limb head, Limb left, Limb right) {
    this->head = head;
    this->left = left;
    this->right = right;
};

Limbs make_limbs(vector<vector<Point> > contours, Point face_center, Mat image) {
    vector<Limb> limbs;
    Limb head, left_hand, right_hand;

    // loop over contours and make limbs
    for (unsigned int i = 0; i < contours.size(); i++) {
        vector<Point> contour = contours.at(i);
        Limb limb(contour, image);
        limbs.push_back(limb);
        if (pointPolygonTest(Mat(contour), face_center, false) > 0) {
            head = limb;
        }
    }

    // sort the limbs
    sort(limbs.begin(), limbs.end(), compare_limbs);
    right_hand = Limb();
    left_hand = Limb();

    // if we know the face
    if (limbs.size() > 2) {
        //loop over 3 biggest limbs
        for(unsigned int i = 0; i < MIN(limbs.size(), 3); i++) {
            if (limbs.at(i).contour == head.contour) {
                continue;
            } else if (limbs.at(i).center.x < face_center.x) {
                left_hand = limbs.at(i);
            } else if (limbs.at(i).center.x > face_center.x) {
                right_hand = limbs.at(i);
            }
        }

    } else if (limbs.size() == 2) {
        head = limbs.at(0);
        Limb hand = limbs.at(1);
        if (hand.center.x < head.center.x) {
            left_hand = hand;
        } else {
            right_hand = hand;
        }

    } else if (limbs.size() == 1) {
        head = limbs.at(0);
    }
    return Limbs(head, left_hand, right_hand);
};