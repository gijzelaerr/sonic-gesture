
#include "matcher.h"
#include "stabilizer.h"


Matcher::Matcher(bool mirror=false) {
    // initialize the HOG parameters
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();

    // construct a vector of the image file names
    char const* solfege_str[] = SOLFEGE_FILES;
    vector<string> solfege(solfege_str, solfege_str + sizeof (solfege_str)/sizeof (*solfege_str));

    // create a stabilizer
    stabilizer = new Stabilizer(solfege.size());
    
    // we keep track of which is the first, so we can extract size info from image
    bool first = true;

    fs::path train_path(TRAIN_PATH);
    assert(fs::exists(train_path));

    vector<fs::path> train_folders;
    fs::directory_iterator end_iter;
    for ( fs::directory_iterator dir_itr( train_path ); dir_itr != end_iter; ++dir_itr ) {
        fs::path train_set = dir_itr->path();

        // skip hidden files
        if (istarts_with(train_set.filename(), ".")) continue;
        train_folders.push_back(train_set);
    }
    
    assert(train_folders.size()>0);

    // loop over folders
    for(unsigned int train_folder=0; train_folder < train_folders.size(); train_folder++) {
        fs::path train_set = train_folders.at(train_folder);

        //loop over images in folders
        for(unsigned int i=0; i < solfege.size(); i++) {
            int imgnum = train_folder * solfege.size() + i;

            labels.push_back(i);

            fs::path hand_path = train_set / solfege.at(i);
            assert(fs::exists(hand_path));

            handimg = imread(hand_path.file_string(), 0);
            if(mirror) flip(handimg, handimg, 1);
            hog.compute(handimg, descriptors, winStride, padding, locations);

            // initialize the matrix with info from first hand
            if(first) {
                train = Mat(descriptors.size(), train_folders.size() * solfege.size(), CV_32FC1);
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

int Matcher::match(vector<float> other_descriptors) {
    CvMat img_cvmat = (Mat)Mat(other_descriptors).t();
    int response = int(knn_matcher.find_nearest(&img_cvmat, 2, 0, 0, 0, 0));
    return this->stabilizer->update(response);
}
