
#ifndef _SETTINGS_H
#define	_SETTINGS_H

#include "cmake.h"

// where to find haar file
#define FACEHAAR DATA_DIR + "/storage/haarcascade_frontalface_alt.xml"

// What (webcam) device or movie to use.
#define DEVICE 0
//#define DEVICE DATA_DIR + "/movies/gijs_train_movie.mov"
//#define DEVICE DATA_DIR + "/movies/gijs_train_lefti.avi"
//#define DEVICE DATA_DIR + "/movies/heiligenacht.mp4"
//#define DEVICE DATA_DIR + "/movies/friend.mov"

#define MAKE_MOVIE TRUE

// window size parameters
#define WORKSIZE 350
#define XWINDOWS 2

// Limb settings
#define INFLATE_SIZE 1.1

// threshold for probabilistic image to binary image
#define THRESHOLD 30

// minimum blob size in square pixels
#define MIN_BLOB_SIZE (WORKSIZE/10)*(WORKSIZE/10)

// which dataset to use
#define DATASET DATA_DIR + "/sets/inout28/"

// temporary here
#define STARTSCREEN DATA_DIR + "../qt/images/background.jpg"

#define NN 3
#endif
