
#include <iostream>
#include <stdlib.h>
#include "boost/filesystem.hpp"
#include "boost/algorithm/string.hpp"
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "skin.h"
#include "hand.h"
#include "settings.h"


using namespace std;
using namespace boost;
using namespace cv;
namespace fs = boost::filesystem;

int main(int argc, char** argv) {

    char const* solfege_str[] = {"do", "re", "mi", "fa", "sol", "la", "ti" };
    vector<string> solfege(solfege_str, solfege_str + sizeof (solfege_str)/sizeof (*solfege_str));

    fs::path train_path(TRAIN_PATH );
    assert(fs::exists(train_path));

    fs::directory_iterator end_iter;
    for ( fs::directory_iterator dir_itr( train_path ); dir_itr != end_iter; ++dir_itr ) {
        fs::path train_set = dir_itr->path();

        // skip hidden files
        if (istarts_with(train_set.filename(), ".")) continue;

        fs::path head_path = train_set / "head.jpg";
        if(!fs::exists(head_path)) {
            cerr << "cant find file " << head_path.file_string() << endl;
            return 1;
        }

        Skin skin(head_path.file_string(), FACEHAAR);


        vector<string>::iterator solfege_iterator = solfege.begin();
        while( solfege_iterator != solfege.end() ) {
            fs::path hand_path = train_set / (*solfege_iterator + ".jpg");
            if(!fs::exists(hand_path)) {
                cerr << "cant find file " << hand_path.file_string() << endl;
                return 1;
            }

            cout << hand_path.file_string() << endl;
            Hand hand(hand_path.file_string(), skin.histogram);

            ++solfege_iterator;
        }
    }
    
    return (EXIT_SUCCESS);
}

