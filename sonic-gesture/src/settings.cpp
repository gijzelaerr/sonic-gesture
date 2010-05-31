
#include "cmake.h"
#include "settings.h"
#include <iostream>

Settings* Settings::m_pSettings = NULL;

Settings* Settings::getInstance() {
    if(m_pSettings == NULL)
       m_pSettings = new Settings;
    return m_pSettings;
}

Settings::Settings() {
     qSettings = new QSettings("Gijs Molenaar", "Sonic Gesture");
     load();
}

Settings::~Settings() {
    save();
    delete qSettings;
}

void Settings::destroy() {
 m_pSettings->save();
 delete m_pSettings;
 m_pSettings=NULL;
}

void Settings::load()  {
     moviePath = QDir(qSettings->value("moviePath", ".").toString());
     dataPath = QDir(qSettings->value("dataPath", QString(DATA_DIR)).toString());
     dataSet = qSettings->value("dataSet", dataPath.path() + "/dataset").toString();
     cvWorkWinHight = qSettings->value("cvWorkWinHight", 300).toInt();
     cvWorkWinInX = qSettings->value("cvWorkWinInX", 2).toInt();
     limbInflationRatio = qSettings->value("limbInflationRatio", 1.1).toDouble();
     probToBinThresh = qSettings->value("probToBinThresh", 30).toInt();
     kNeirNeigh = qSettings->value("kNeirNeigh", 3).toInt();

     QString haar(dataPath.absolutePath() + QString("/storage/haarcascade_frontalface_alt.xml"));
     std::cout << haar.toStdString() << std::endl;
     haarFile = QFileInfo(haar);
     minBlobSize = (cvWorkWinHight/10)*(cvWorkWinHight/10);

     FPS = 25;
 };

 void Settings::save() {
     qSettings->setValue("moviePath", moviePath.absolutePath());
     qSettings->setValue("dataPath", dataPath.absolutePath());
     qSettings->setValue("dataSet", dataSet.absolutePath());
     qSettings->setValue("cvWorkWinHight", cvWorkWinHight);
     qSettings->setValue("cvWorkWinInX", cvWorkWinInX);
     qSettings->setValue("limbInflationRatio", limbInflationRatio);
     qSettings->setValue("probToBinThresh", probToBinThresh);
     qSettings->setValue("kNeirNeigh", kNeirNeigh);
     qSettings->sync();

};
