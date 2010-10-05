#include "settings.h"
#include "loader.h"
#include "tools.h"
#include <QtDebug>

#include "cv.h"
#include "cvaux.h"

#include <iostream>
#include <fstream>

using namespace std;



int main(int argc, char *argv[]) {
    Settings* settings = Settings::getInstance();
    std::vector<int> real_labels;
    std::vector<float> labels_vector;
    bool mirror = false;
    Size winStride, padding;
    HOGDescriptor hog;
    vector<Point> locations;
    vector<float> descriptors;
    vector<KeyPoint> keypoints;
    SURF surf;

    Mat handimg;
    Mat train_mat;
    Mat labels_mat;

    int xsize = 64;
    int ysize = 128;
    int winsize = 16;

    int xpt, ypt;
    for (int x = 0; x < (xsize/winsize)*2-1; x++ ) {
        for (int y = 0; y < (ysize/winsize)*2-1; y++ ) {
            xpt = (x+1)*(winsize/2);
            ypt = (y+1)*(winsize/2);
            keypoints.push_back(KeyPoint(Point(xpt, ypt), winsize));
        }
    };


    QFileInfo labelsPath(settings->dataSet.absolutePath() + "/labels.txt");
    if (!labelsPath.isReadable()) {
        cout << QString("file %1 is not readable").arg(labelsPath.filePath()).toStdString() << endl;
        exit(EXIT_FAILURE);
    };

    ifstream file;
    string lineread;
    int i;
    file.open(labelsPath.filePath().toStdString().c_str(), ifstream::in);

    while(std::getline(file, lineread)) {
        istringstream myStream(lineread);
        if (myStream>>i) {
            real_labels.push_back(i);
        } else {
            break;
        }

    };

    // initialize the HOG parameters
    hog = HOGDescriptor();
    surf = SURF();


    // we keep track of which is the first, so we can extract size info from image
    bool first = true;

    QDir data_path(settings->dataSet);
    qDebug() << "using dataset " << data_path.path();

    QDir train_path(settings->dataSet.path() + "/train");
    assert(data_path.exists());
    assert(train_path.exists());

    QStringList trainSets;
    QStringList trainList = train_path.entryList();
    for (int i = 0; i < trainList.size(); ++i) {
         QString trainSet = trainList.at(i);
         if (trainSet.startsWith("."))
             continue;
         trainSets.append(trainSet);

    };
    assert(trainSets.size()>0);

    // loop over folders
    for(unsigned int trainNum=0; trainNum < trainSets.size(); trainNum++) {
        QString trainSet = trainSets.at(trainNum);

        //loop over images in folders
        for(unsigned int i=0; i < real_labels.size(); i++) {
            int imgnum = trainNum * real_labels.size() + i;

            labels_vector.push_back(real_labels.at(i));

            QFileInfo handPath(train_path.path() + QString("/%1/%2.jpg").arg(trainSet).arg(i));
            assert(handPath.exists());

            string handPathString = handPath.filePath().toStdString();
            Mat handimg = cv::imread(handPathString, 0);
            if(mirror) flip(handimg, handimg, 1);

            if (!handimg.data) {
                std::cout << "ERROR: can't read image: " << handPathString << std::endl;
                exit(EXIT_FAILURE);
            };

            // UNCOMMENT THIS TO USE HOG
            hog.compute(handimg, descriptors, winStride, padding, locations);

            // UNCOMMENT THIS TO USE SURF
            //surf(handimg, Mat(), keypoints, descriptors, true);

            // initialize the matrix with info from first hand
            if(first) {
                train_mat = Mat(descriptors.size(), trainSets.size() * real_labels.size(), CV_32FC1);
                first = false;
            }

            Mat descr(descriptors);
            Mat t = train_mat.col(imgnum);
            descr.copyTo(t);
        }
    }
    train_mat = train_mat.t();
    labels_mat = Mat(labels_vector);



    QFile* features = new QFile("features.txt");
    if (!features->open(QIODevice::WriteOnly | QIODevice::Text)) {
        cout << "cant open feature file" << endl;
        exit(EXIT_FAILURE);
    };

    QTextStream outfeatures(features);
    for (int y=0; y < train_mat.rows; y++) {
        for (int x=0; x < train_mat.cols; x++) {
            float val = train_mat.at<float>(y, x);
            outfeatures << val << "\t";
        }
        outfeatures << endl;
    }


    QFile* labels = new QFile("labels.txt");
    if (!labels->open(QIODevice::WriteOnly | QIODevice::Text)) {
        cout << "cant open labels file" << endl;
        exit(EXIT_FAILURE);
    };

    QTextStream outlabels(labels);
    for (int y=0; y < labels_mat.rows; y++) {
        for (int x=0; x < labels_mat.cols; x++) {
            float val = labels_mat.at<float>(y, x);
            outlabels << val << "\t";
        }
        outlabels << endl;
    }



    QFile* sets = new QFile("sets.txt");
    if (!sets->open(QIODevice::WriteOnly | QIODevice::Text)) {
        cout << "cant open sets file" << endl;
        exit(EXIT_FAILURE);
    };

    QTextStream outsets(sets);
    for(unsigned int trainNum=0; trainNum < trainSets.size(); trainNum++) {
        string bla = trainSets.at(trainNum).toStdString();
        outsets << bla.c_str() << endl;
    }




};
