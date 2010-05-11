
//#include <iosfwd>

#include "matcher.h"
#include <boost/algorithm/string/predicate.hpp>



// mirror: should the training images be mirrored, default is left hand
Matcher::Matcher(bool mirror, vector<int> example_labels) {
    // initialize the HOG parameters
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();



    // create a stabilizer
    stabilizer = new Stabilizer(example_labels.size());
    
    // we keep track of which is the first, so we can extract size info from image
    bool first = true;

    fs::path data_path(DATASET);
    fs::path train_path = data_path / "train";
    assert(fs::exists(data_path));
    assert(fs::exists(train_path));

    vector<fs::path> train_folders;
    fs::directory_iterator end_iter;
    for ( fs::directory_iterator dir_itr( train_path ); dir_itr != end_iter; ++dir_itr ) {
        fs::path train_set = dir_itr->path();

        // skip hidden files
        if (boost::starts_with(train_set.filename(), ".")) continue;
        train_folders.push_back(train_set);
    }
    
    assert(train_folders.size()>0);

    // loop over folders
    for(unsigned int train_folder=0; train_folder < train_folders.size(); train_folder++) {
        fs::path train_set = train_folders.at(train_folder);

        //loop over images in folders
        for(unsigned int i=0; i < example_labels.size(); i++) {
            int imgnum = train_folder * example_labels.size() + i;

            labels.push_back(example_labels.at(i));
            
            fs::path hand_path = train_set / (int2string(i) + ".jpg");
            assert(fs::exists(hand_path));

            handimg = imread(hand_path.file_string(), 0);
            if(mirror) flip(handimg, handimg, 1);
            hog.compute(handimg, descriptors, winStride, padding, locations);

            // initialize the matrix with info from first hand
            if(first) {
                train = Mat(descriptors.size(), train_folders.size() * example_labels.size(), CV_32FC1);
                first = false;
            }

            Mat descr(descriptors);
            Mat t = train.col(imgnum);
            descr.copyTo(t);
        }
    }
    train = train.t();
    labels_mat = Mat(labels);
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
    int response = int(knn_matcher.find_nearest(&img_cvmat, 2, 0, 0, 0, 0));
    return this->stabilizer->update(response);
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
            //cout << "update " << i << " with " << new_val;
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


