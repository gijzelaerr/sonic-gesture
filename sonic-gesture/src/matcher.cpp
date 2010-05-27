
#include "matcher.h"
#include "highgui.h"
#include "tools.h"
#include <QtCore/QDir>

// mirror: should the training images be mirrored, default is left hand
Matcher::Matcher(bool mirror, vector<int> labels) {

    settings = Settings::getInstance();
    
    // initialize the HOG parameters
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();

    // create a stabilizer
    stabilizer = new Stabilizer(labels.size());
    
    // we keep track of which is the first, so we can extract size info from image
    bool first = true;

    QDir data_path(settings->dataSet);
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

            handimg = cv::imread(handPath.filePath().toStdString(), 0);
            if(mirror) flip(handimg, handimg, 1);
            hog.compute(handimg, descriptors, winStride, padding, locations);

            // initialize the matrix with info from first hand
            if(first) {
                train = Mat(descriptors.size(), trainSets.size() * labels.size(), CV_32FC1);
                first = false;
            }

            Mat descr(descriptors);
            Mat t = train.col(imgnum);
            descr.copyTo(t);
        }
    }
    train = train.t();
    labels_mat = Mat(this->labels);
    knn_matcher = KNearest();
    cout << "traing matcher with " << train.rows << " examples with " <<
            train.cols << " features..." << endl;
    knn_matcher.train(train, labels_mat);
}

Matcher::~Matcher() {
    delete stabilizer;
};

int Matcher::match(const vector<float>& other_descriptors) {
    CvMat img_cvmat = (Mat)Mat(other_descriptors).t();
    int response = int(knn_matcher.find_nearest(&img_cvmat, settings->kNeirNeigh, 0, 0, 0, 0));
    return this->stabilizer->update(response);
    //return response;
}


Stabilizer::Stabilizer(int state_num) {
    for (int i = 0; i < state_num; i++) {
        this->states.push_back(STATE_MIN);
    }
};

Stabilizer::~Stabilizer() {
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


