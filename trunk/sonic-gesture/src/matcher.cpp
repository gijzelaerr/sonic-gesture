
#include "matcher.h"
#include "highgui.h"
#include "tools.h"
#include <QtCore/QDir>
#include <QtDebug>

//#define USE_SVM
#define USE_PCA


Matcher::Matcher() {
}

Matcher::~Matcher() {
    // TODO: somehow this is already detroyed before we come here....
    this->knn_matcher = KNearest();
}


// mirror: should the training images be mirrored, default is left hand
Matcher::Matcher(bool mirror, vector<int> labels) {

    settings = Settings::getInstance();
    
    // initialize the HOG parameters
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();

    // create a stabilizer
    stabilizer = Stabilizer(labels.size());
    
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
        for(unsigned int i=0; i < labels.size(); i++) {
            int imgnum = trainNum * labels.size() + i;

            this->labels.push_back(labels.at(i));
            
            QFileInfo handPath(train_path.path() + QString("/%1/%2.jpg").arg(trainSet).arg(i));
            assert(handPath.exists());

            string handPathString = handPath.filePath().toStdString();
            handimg = cv::imread(handPathString, 0);
            if(mirror) flip(handimg, handimg, 1);

            // TODO: make error handling, set error, return false, bla bla
            if (!handimg.data) {
                std::cout << "ERROR: can't read image: " << handPathString << std::endl;
                return;
            };
            hog.compute(handimg, descriptors, winStride, padding, locations);

            // initialize the matrix with info from first hand
            if(first) {
                train_mat = Mat(descriptors.size(), trainSets.size() * labels.size(), CV_32FC1);
                first = false;
            }

            Mat descr(descriptors);
            Mat t = train_mat.col(imgnum);
            descr.copyTo(t);
        }
    }
    train_mat = train_mat.t();
    labels_mat = Mat(this->labels);

    //qDebug() << "traing matcher with " << train.rows << " examples with " <<
    //        train.cols << " features...";
    train(train_mat, labels_mat);

}


void Matcher::train(Mat train_mat, Mat labels_mat) {
#ifdef USE_PCA
    int maxComponents = 10;
    PCA pca(train_mat, Mat(), CV_PCA_DATA_AS_ROW, maxComponents);
    train_mat = pca.project(train_mat);
#endif

#ifdef USE_SVM
    svm_matcher = CvSVM();
    svm_matcher.train(train_mat, labels_mat);
#else
    knn_matcher = KNearest();
    knn_matcher.train(train_mat, labels_mat);
#endif
}

int Matcher::match(const vector<float>& other_descriptors) {
    Mat sample = Mat(other_descriptors).t();
    int response;

#ifdef USE_PCA
    sample = pca.project(sample);
#endif

#ifdef USE_SVM
    response = int(svm_matcher.predict(sample, false));
#else
    CvMat img_cvmat = sample;
    response = int(knn_matcher.find_nearest(&img_cvmat, settings->kNeirNeigh, 0, 0, 0, 0));
#endif

    return this->stabilizer.update(response);
    //return response;
}

Stabilizer::Stabilizer(int state_num) {
    for (int i = 0; i < state_num; i++) {
        this->states.push_back(STATE_MIN);
    }
};

Stabilizer::Stabilizer() {
    states.clear();
}

Stabilizer::~Stabilizer() {
    states.clear();
};

// update stabilizer with new measurement. Decrease all non-measured states
int Stabilizer::update(int state) {
    assert(state <= (int)this->states.size());
    int new_val;

    for (int i = 0; i < (int)this->states.size(); i++) {
        if (i == state) {
            new_val = min(this->states.at(i)+1, STATE_MAX);
            this->states.at(i) = new_val;
            if ((new_val >= STATE_THRESH) && (!this->active)) {
                this->trigger(true, i);
            }
        } else {
            new_val = max(this->states.at(i)-1, STATE_MIN);
            this->states.at(i) = new_val;
            if ((new_val < STATE_THRESH) && (this->active)) {
                this->trigger(false, i);
            }
        }
    }
    return this->get_state();
};

// return num of max state
int Stabilizer::get_state() {
    int max_val = -1;
    int val, max_state;

    for (unsigned int i = 0; i < this->states.size(); i++) {
        val = this->states.at(i);
        if (val > max_val) {
            max_state = i;
            max_val = val;
        }
    }
    if (max_val > STATE_THRESH) {
        return max_state;
    } else {
        return -1;
    }
};

void Stabilizer::trigger(bool new_active, int new_state) {
    this->active = new_active;
}

bool Stabilizer::is_active() {
    return this->active;
}

void Stabilizer::set_callback() {

};


