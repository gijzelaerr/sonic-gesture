
#ifndef _SETTINGS_H
#define	_SETTINGS_H

#include "cmake.h"
#include <QtCore/QString>
#include <QtCore/QSettings>

// where to find haar file
//#define FACEHAAR DATA_DIR + "/storage/haarcascade_frontalface_alt.xml"

// window size parameters
//#define WORKSIZE 350
//#define XWINDOWS 2

// Limb settings
//#define INFLATE_SIZE 1.1

// threshold for probabilistic image to binary image
//#define THRESHOLD 30

// minimum blob size in square pixels
//#define MIN_BLOB_SIZE (WORKSIZE/10)*(WORKSIZE/10)

// which dataset to use
//#define DATASET DATA_DIR + "/sets/inout28/"

// temporary here
//#define STARTSCREEN DATA_DIR + "/../qt/images/background.jpg"

//#define NN 3


class Settings {
protected:
    Settings();
public:
    virtual ~Settings();
    static Settings* getInstance();
    static void destroy();
private:
    static Settings* m_pSettings;

public:
    // locations
    QString moviePath;
    QString dataPath;
    QString dataSet;
    QString haarFile;

    // window size parameters
    int cvWorkWinHight;
    int cvWorkWinInX;

    // Limb settings
    double limbInflationRatio;

    // threshold for probabilistic image to binary image
    int probToBinThresh;

    // Threshold for filtering out small blobs
    int minBlobSize;

    // matcher parameters
    int kNeirNeigh;
    
private:
    void load();
    void save();
    QSettings* qSettings;
};



#endif
