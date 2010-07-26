
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
     dataSet = qSettings->value("dataSet", dataPath.path() + "/sets/all").toString();
     cvWorkWinHight = qSettings->value("cvWorkWinHight", 200).toInt();
     cvWorkWinInX = qSettings->value("cvWorkWinInX", 2).toInt();
     limbInflationRatio = qSettings->value("limbInflationRatio", 1.1).toDouble();
     probToBinThresh = qSettings->value("probToBinThresh", 20).toInt(); // was 30!!!
     kNeirNeigh = qSettings->value("kNeirNeigh", 3).toInt();
     deviceId = qSettings->value("deviceId", 0).toInt();
     blur = qSettings->value("blur", 31).toInt(); // 31 untill now

     haarFile = QFileInfo(dataPath.path() + QString("/storage/haarcascade_frontalface_alt.xml"));
     minBlobSize = (cvWorkWinHight/20)*(cvWorkWinHight/20);

     FPS = 10;
 };

 void Settings::save() {
     qSettings->setValue("moviePath", moviePath.absolutePath());
     qSettings->setValue("dataPath", dataPath.absolutePath());
     //qSettings->setValue("dataSet", dataSet.absolutePath());
     //qSettings->setValue("cvWorkWinHight", cvWorkWinHight);
     //qSettings->setValue("cvWorkWinInX", cvWorkWinInX);
     //qSettings->setValue("limbInflationRatio", limbInflationRatio);
     //qSettings->setValue("probToBinThresh", probToBinThresh);
     //qSettings->setValue("kNeirNeigh", kNeirNeigh);
     //qSettings->setValue("deviceId", deviceId);
     qSettings->setValue("blur", blur);
     qSettings->sync();

};
