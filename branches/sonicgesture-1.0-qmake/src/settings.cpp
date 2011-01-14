/*!
 * \brief A settings class containing all settings.
 *
 * There is no settings screen at the moment but maybe there will be some day
 *
 */

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
     dataPath = QDir(qSettings->value("dataPath", QDir::currentPath() + "/data").toString());
     dataSet = qSettings->value("dataSet", dataPath.path() + "/sets/subset").toString();
     cvWorkWinHight = qSettings->value("cvWorkWinHight", 200).toInt();
     cvWorkWinInX = qSettings->value("cvWorkWinInX", 2).toInt();
     limbInflationRatio = qSettings->value("limbInflationRatio", 1.1).toDouble();
     probToBinThresh = qSettings->value("probToBinThresh", 10).toInt(); // was 30 in beginning, 20 for complete dataset
     kNeirNeigh = qSettings->value("kNeirNeigh", 3).toInt();
     deviceId = qSettings->value("deviceId", 0).toInt();
     blur = qSettings->value("blur", 11).toInt(); // 31 for complete dataset

     haarFile = QFileInfo(dataPath.path() + QString("/storage/haarcascade_frontalface_alt.xml"));
     minBlobSize = (cvWorkWinHight/20)*(cvWorkWinHight/20);

     FPS = 25;
 };

 void Settings::save() {
     //qSettings->setValue("moviePath", moviePath.absolutePath());
     //qSettings->setValue("dataPath", dataPath.absolutePath());
     //qSettings->setValue("dataSet", dataSet.absolutePath());
     //qSettings->setValue("cvWorkWinHight", cvWorkWinHight);
     //qSettings->setValue("cvWorkWinInX", cvWorkWinInX);
     //qSettings->setValue("limbInflationRatio", limbInflationRatio);
     //qSettings->setValue("probToBinThresh", probToBinThresh);
     //qSettings->setValue("kNeirNeigh", kNeirNeigh);
     //qSettings->setValue("deviceId", deviceId);
     //qSettings->setValue("blur", blur);
     qSettings->sync();

};
