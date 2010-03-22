

#include <iostream>
#include <exception>

#include "cv.h"
#include "cvaux.h"
#include "ml.h"

#include "finder.h"
#include "tools.h"
#include "settings.h"
#include "limb.h"


using namespace cv;
using namespace std;

// histogram stuff
int hbins = 30, sbins = 32;
int histSize[] = {hbins, sbins};
const float hranges[] = { 0, 180 };
const float sranges[] = { 0, 256 };
const float* ranges[] = { hranges, sranges };
int channels[] = {0, 1};

Finder::Finder(VideoCapture c) {
    if(!c.isOpened()) {
		cout << "couldn't open video\n";
        throw exception();
    }
    cap = c;
    haar = CascadeClassifier(FACEHAAR);
    cap >> frame;
    frame_size = frame.size();
    scale = float(WORKSIZE)/frame.rows;
    resize(frame, small, Size(), scale, scale);
    small_size = small.size();

    histogram.create(2, histSize, CV_32F);
    histogram = Scalar(0);

}

void Finder::grab_frame() {
    cap >> frame;
    if (!frame.data) {
		cout << "end of movie" << endl;
        throw exception();
    }
    resize(frame, small, Size(), scale, scale);
    flip(small, small, 1);
    cvtColor(small, hsv, CV_BGR2HSV);
    cvtColor(small, bw, CV_BGR2GRAY);
}

void Finder::make_histogram() {
    if (!(face == Rect())) {
        facepixels = hsv(face);
        old_hist = new_hist;
        calcHist( &facepixels,  1, channels, Mat(), new_hist, 2,  histSize, ranges,  true, false );
        if (new_hist.type() == old_hist.type()) {
            //double diff = compareHist(new_hist, old_hist, CV_COMP_BHATTACHARYYA);
            add(new_hist, old_hist, histogram);
        } 
        histogram = new_hist;
        normalize(histogram, histogram, 255);
    }
}

void Finder::make_backproject() {
    calcBackProject( &hsv, 1, channels, histogram, backproj, ranges );
}

void Finder::make_mask() {
    normalize(backproj, backproj, 0, 255, NORM_MINMAX);
    GaussianBlur( backproj, blurred, Size(31, 31), 0);
    threshold(blurred, th, 20, 255, THRESH_BINARY);
    int dia = WORKSIZE/20 + 1;
    Mat kernel = Mat(dia, dia, CV_8U, 1);
    //morphologyEx(th, mask, MORPH_CLOSE, Mat());
    dilate(th, mask, kernel, Point(ceil(dia/2.0), ceil(dia/2.0)));
}

void Finder::find_contours() {
    findContours( mask, contours, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
}
	
void Finder::find_face() {
    //haar.detectMultiScale(small, faces, 1.2, 2, CV_HAAR_SCALE_IMAGE +
    //    CV_HAAR_DO_CANNY_PRUNING + CV_HAAR_FIND_BIGGEST_OBJECT, Size(WORKSIZE/10, WORKSIZE/10) );
    haar.detectMultiScale(small, faces, 1.3, 3, CV_HAAR_DO_CANNY_PRUNING +
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

    for (unsigned int i = 0; i < contours.size(); i++) {
        vector<Point> contour = contours.at(i);
        Limb limb = Limb(contour);
        limbs.push_back(limb);
        if (pointPolygonTest(contour, facepoint, false) > 0) {
            head = limb;
        }
    }

    sort(limbs.begin(), limbs.end(), compare_limbs);
    right_hand = Limb();
    left_hand = Limb();

    // if we know the face
    if (!(face == Rect())) {
        //loop over 3 biggest limbs
        for(unsigned int i = 0; i < MIN(limbs.size(), 3); i++) {
            if (limbs.at(i).contour == head.contour) {
                continue;
            } else if (limbs.at(i).center.x < facepoint.x) {
                left_hand = limbs.at(i);
            } else if (limbs.at(i).center.x > facepoint.x) {
                right_hand = limbs.at(i);
            }
        }
    }else {
        
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
            if (hand.center.x < head.center.x) {
                left_hand = hand;
            } else {
                right_hand = hand;
            }

        } else if (limbs.size() == 1) {
            head = limbs.at(0);
        }
    }
};

void Finder::visualize() {
    small.copyTo(visuals);
    convertScaleAbs(visuals, visuals, 0.2);
    small.copyTo(visuals, mask);
    rectangle(small, face.tl(), face.br(), Scalar(0, 255, 0));
	
    if (head.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(head.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 0, 255 ));
    }

    if (left_hand.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(left_hand.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 255, 0 ));
    }    
    
    if (right_hand.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(right_hand.contour);
        drawContours( visuals, cs, -1, Scalar( 255, 0, 0 ));
    }
    


    presentation.clear();
    presentation.push_back(small);
    presentation.push_back(backproj);
    presentation.push_back(blurred);
    presentation.push_back(th);
    //presentation.push_back(mask);
    presentation.push_back(visuals);
    presentation.push_back(limb_zoom);


    int w = MIN(XWINDOWS, presentation.size())*small_size.width;
    int h = ceil(float(presentation.size())/XWINDOWS)*small_size.height;
    combi.create(Size(w, h), CV_8UC3);
    for(unsigned int i=0; i < presentation.size(); i++) {
        Mat current = presentation.at(i);
        int xoffset = (i % XWINDOWS) * small_size.width;
        int yoffset = (i / XWINDOWS) * small_size.height;
        Mat roi(combi, Rect(xoffset, yoffset, small_size.width, small_size.height));
        if (current.channels() == 3) {
            current.copyTo(roi);
        } else {
            cvtColor(current, roi, CV_GRAY2RGB);
        }
    }
}

void Finder::match_hands() {
    bw.copyTo(limb_zoom);
    limb_zoom = Scalar(0);
    if (left_hand.contour.size() != 0) {
        left_hand.compute_hog(small);
        Mat roi(limb_zoom, Rect(20, 90, left_hand.bw.cols, left_hand.bw.rows));
        left_hand.bw.copyTo(roi);

        Mat test = Mat(left_hand.hog_descriptors).t();
        CvMat cvtest = test;
        //show_mat(test);
        CvMat* nearests = cvCreateMat( 1, 1, CV_32FC1);

        test = Mat(1, 3780, CV_32FC1);
        test = Scalar(3);
        int response = hand_matcher.find_nearest(&cvtest,1, 0, 0, nearests, 0);
        Hand found_hand = hands.at(response);
        Mat found_hand_img = found_hand.cutout;
        roi = Mat(limb_zoom, Rect(100, 90, found_hand_img.cols, found_hand_img.rows));
        found_hand_img.copyTo(roi);

    }

    if (right_hand.contour.size() != 0) {
        right_hand.compute_hog(small);
        Mat roi(limb_zoom, Rect(250, 90, right_hand.bw.cols, right_hand.bw.rows));
        right_hand.bw.copyTo(roi);
    }


}

void Finder::init_hands() {
    Skin skin(HEAD, FACEHAAR);
    hands.push_back(Hand(HANDA, skin.histogram));
    hands.push_back(Hand(HANDB, skin.histogram));
    hands.push_back(Hand(HANDC, skin.histogram));
    hands.push_back(Hand(HANDD, skin.histogram));

    Mat knn_train(hands.at(0).descriptors.size(), hands.size(), CV_32FC1);
    for (unsigned int i = 0; i < hands.size(); i++) {
        Hand hand = hands.at(i);
        Mat handmat(hand.descriptors);
        Mat r = knn_train.col(i);
        handmat.copyTo(r);
    }
    knn_train = knn_train.t();

    float labels[1][4] = {{0, 1, 2, 3}};
    Mat knn_class(4, 1, CV_32FC1, labels);
    knn_class = knn_class.t();

    hand_matcher = KNearest();
    hand_matcher.train(knn_train, knn_class);

}

void Finder::mainloop() {
    init_hands();



    for(;;) {
        double t = (double)getTickCount();
        
        grab_frame();
        find_face();
        make_histogram();
        make_backproject();
        make_mask();
        find_contours();
        find_limbs();
        match_hands();
        visualize();
        imshow("Sonic Gesture", combi);
        
        t = ((double)getTickCount() - t)*1000/getTickFrequency();
        int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;
        if(waitKey(wait) >= 0)
            break;
    }
}




