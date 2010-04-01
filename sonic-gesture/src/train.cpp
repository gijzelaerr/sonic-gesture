
#include "common.h"

int main(int argc, char** argv) {
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    HOGDescriptor hog = HOGDescriptor();
    vector<float> descriptors;
    Mat handimg;
    Mat knn_train;
    Mat knn_label;
    char const* solfege_str[] = SOLFEGE_FILES;
    vector<string> solfege(solfege_str, solfege_str + sizeof (solfege_str)/sizeof (*solfege_str));
    bool first = true;

    fs::path train_path(TRAIN_PATH);
    assert(fs::exists(train_path));

    fs::directory_iterator end_iter;
    for ( fs::directory_iterator dir_itr( train_path ); dir_itr != end_iter; ++dir_itr ) {
        fs::path train_set = dir_itr->path();

        // skip hidden files
        if (istarts_with(train_set.filename(), ".")) continue;

        for(unsigned int i=0; i < solfege.size(); i++) {
            fs::path hand_path = train_set / solfege.at(i);
            assert(fs::exists(hand_path));
            handimg = imread(hand_path.file_string());

            hog.compute(handimg, descriptors, winStride, padding, locations);

            // initialize the matrix with info from first hand
            if(first) {
                knn_train = Mat(descriptors.size(), solfege.size(), CV_32FC1);
                knn_label = (1, solfege.size(), CV_32FC1)
                first = false;
            }

            Mat handmat(descriptors);
            Mat r = knn_train.col(i);
            handmat.copyTo(r);
        }
    }
    knn_train = knn_train.t();
    KNearest matcher = KNearest();
    matcher.train(knn_train, knn_label);
    fs::path data_path(DATA_DIR);
    fs::path knn_file = data_path / "storage" / "knn.xml";
    matcher.save(knn_file.file_string());

    return (EXIT_SUCCESS);
}

