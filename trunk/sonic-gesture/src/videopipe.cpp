
#include "videopipe.h"

#include <iostream>
#include <exception>

#include "finder.h"
#include "histogram.h"


using namespace cv;
using namespace std;


Videopipe::Videopipe() {
    cout << "starting with device " << DEVICE << "." << endl;
    this->cap = VideoCapture(device);
    this->init();
}

VideoPipe::Videopipe(string movie) {
    cout << "starting with movie " << movie << "." << endl;
    // TODO: add check if file exists
    this->cap = VideoCapture(movie);
    this->init();
}

Finder::~Finder() {
    delete histogram;
    
};

void Finder::init() {
    if(!this->cap.isOpened()) {
        cout << "couldn't open capture device!\n";
        exit(1);
    }
    
    // grab first frame
    this->grab_frame();
    
    // resize image to worksize, and store size and scale info
    this->big_size = this->big.size();
    this->scale = float(WORKSIZE)/this->big.rows;
    
    this->prepare_frame();
    this->small_size = this->small_.size();
    
    // load haar stuff
    fs::path haar_path(FACEHAAR);
    assert(fs::exists(haar_path));
    this->haar = CascadeClassifier(FACEHAAR);
    
    histogram = new Histogram();
    
    // do one step to initialize everything
    step();
}




// Preprocessing step, resize and convert color
void Finder::prepare_frame() {
    if(MIRROR) flip(this->big, this->big, 1);
    resize(this->big, this->small_, Size(), this->scale, this->scale);
    cvtColor(this->small_, this->hsv, CV_BGR2HSV);
    cvtColor(this->small_, this->bw, CV_BGR2GRAY);
}

void Finder::make_histogram() {
    if (!(this->face == Rect())) {
        facepixels = hsv(face);
        this->histogram->update(facepixels);
    }
}


void Finder::make_backproject() {
    backproj = this->histogram->backproject(hsv);
}


void Finder::make_mask() {
    normalize(backproj, backproj, 0, 255, NORM_MINMAX);
    GaussianBlur( backproj, blurred, Size(31, 31), 0);
    threshold(blurred, th, THRESHOLD, 255, THRESH_BINARY);
    int dia = WORKSIZE/20 + 1;
    Mat kernel = round_kernel(dia);
    morphologyEx(th, mask, MORPH_CLOSE, Mat());
    //dilate(th, mask, kernel, Point(ceil(dia/2.0), ceil(dia/2.0)));
}


void Finder::find_contours() {
    findContours( mask, contours, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
}


void Finder::find_face() {
    haar.detectMultiScale(small_, faces, 1.3, 3, CV_HAAR_DO_CANNY_PRUNING +
        CV_HAAR_FIND_BIGGEST_OBJECT, Size(WORKSIZE/10, WORKSIZE/10) );
    
    if (faces.size() > 0) {
        face = faces.at(0);
        face = sub_region(face);
    } else {
        face = Rect();
    }
}

void Finder::find_limbs() {
    Point facepoint = Point(face.x+face.width/2, face.y+face.height/2);
    vector<Limb> limbs;
    
    // loop over contours and make limbs
    for (unsigned int i = 0; i < contours.size(); i++) {
        vector<Point> contour = contours.at(i);
        Limb limb(contour, scale, big);
        limbs.push_back(limb);
        if (pointPolygonTest(Mat(contour), facepoint, false) > 0) {
            head = limb;
        }
    }
    
    // sort the limbs
    sort(limbs.begin(), limbs.end(), compare_limbs);
    right_hand = Limb();
    left_hand = Limb();
    
    // if we know the face
    if (!(face == Rect())) {
        //loop over 3 biggest limbs
        for(unsigned int i = 0; i < MIN(limbs.size(), 3); i++) {
            if (limbs.at(i).contour_small == head.contour_small) {
                continue;
            } else if (limbs.at(i).center_small.x < facepoint.x) {
                left_hand = limbs.at(i);
            } else if (limbs.at(i).center_small.x > facepoint.x) {
                right_hand = limbs.at(i);
            }
        }
    } else {
        if (limbs.size() > 2) {
            vector<Limb>  three_limbs;
            for(int i=0; i<3; i++) {
                three_limbs.push_back(limbs.at(i));
            }
            sort(three_limbs.begin(), three_limbs.end(), compare_limbs_xpos);
            left_hand = three_limbs.at(0);
            head = three_limbs.at(1);
            right_hand = three_limbs.at(2);
            
        } else if (limbs.size() == 2) {
            head = limbs.at(0);
            Limb hand = limbs.at(1);
            if (hand.center_small.x < head.center_small.x) {
                left_hand = hand;
            } else {
                right_hand = hand;
            }
            
        } else if (limbs.size() == 1) {
            head = limbs.at(0);
        }
    }
};


bool Finder::step() {
    double t = (double)getTickCount();
    
    if(!grab_frame())
        return false;
    prepare_frame();
    find_face();
    make_histogram();
    make_backproject();
    make_mask();
    find_contours();
    find_limbs();
    match_hands();
    visualize();
    
    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;
    
    if(waitKey(wait) >= 0)
        return false;
    return true;
}    

void Finder::run() {
    while (this->step()){
        imshow("Sonic Gesture", combi);
    };
}




