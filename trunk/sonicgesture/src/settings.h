
#ifndef _SETTINGS_H
#define	_SETTINGS_H

#include "cmake.h"
#include <QtCore/QString>
#include <QtCore/QSettings>
#include <QtCore/QDir>
#include <QtCore/QFile>

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
    QDir moviePath;
    QDir dataPath;
    QDir dataSet;
    QFileInfo haarFile;

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

    // frames per second
    double FPS;

    // which camera to use
    int deviceId;

    // amount of blurring of probabilistic skin image
    int blur;
    
private:
    void load();
    void save();
    QSettings* qSettings;
};



#endif
