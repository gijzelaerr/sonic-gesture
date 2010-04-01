
#ifndef _COMMON_H
#define	_COMMON_H

// opencv stuff
#include "cv.h"
#include "cvtypes.h"
#include "highgui.h"
#include "ml.h"
#include "cvaux.h"

// boost stuff
#include "boost/filesystem.hpp"
#include "boost/algorithm/string.hpp"

// sonic gesture stuff
#include "settings.h"
#include "tools.h"

// solfege file names
#define SOLFEGE_FILES { "00_do.jpg", "01_di.jpg", "02_re.jpg", "03_ri.jpg", "04_mi.jpg", "05_fa.jpg", "06_fi.jpg", "07_sol.jpg", "08_si.jpg", "09_la.jpg", "10_li.jpg", "11_ti.jpg"}

// we don't need no stinkin opencv 1.0
#define CV_NO_BACKWARD_COMPATIBILITY

using namespace cv;
using namespace std;
using namespace boost;
namespace fs = boost::filesystem;

#endif