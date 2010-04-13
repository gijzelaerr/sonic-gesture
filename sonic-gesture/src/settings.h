
#ifndef _SETTINGS_H
#define	_SETTINGS_H

#include "cmake.h"

// flip image or not
#define MIRROR false

// where to find everything
#define SKIN DATA_DIR + "/hand/skin.png"
#define HEAD DATA_DIR + "/hand/head.png"
#define HANDA DATA_DIR + "/hand/a.png"
#define HANDB DATA_DIR + "/hand/b.png"
#define HANDC DATA_DIR + "/hand/c.png"
#define HANDD DATA_DIR + "/hand/d.png"
#define FACEHAAR DATA_DIR + "/storage/haarcascade_frontalface_alt.xml"
#define TRAIN_PATH DATA_DIR + "/train"
#define NEWTRAIN_PATH DATA_DIR + "/train_new"
#define EXAMPLES_PATH DATA_DIR + "/examples"


// What (webcam) device or movie to use.
//#define DEVICE 0
#define DEVICE DATA_DIR + "/movies/gijs_train_movie.mov"
//#define DEVICE DATA_DIR + "/movies/gijs_train_lefti.avi"
//#define DEVICE DATA_DIR + "/movies/heiligenacht.mp4"
//#define DEVICE DATA_DIR + "/movies/friend.mov"

#define MAKE_MOVIE TRUE

// window size parameters
#define WORKSIZE 300
#define XWINDOWS 3

// Limb settings
#define INFLATE_SIZE 1.5

#endif
