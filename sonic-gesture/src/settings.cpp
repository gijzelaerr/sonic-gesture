
#include "settings.h"

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
 delete m_pSettings;
 m_pSettings=NULL;
}

void Settings::save()  {
     moviePath = qSettings->value("moviePath", ".").toString();
     dataPath = qSettings->value("dataPath", ".").toString();
     dataSet = qSettings->value("dataSet", ".").toString();
     cvWorkWinHight = qSettings->value("cvWorkWinHight", 300).toInt();
     cvWorkWinInX = qSettings->value("cvWorkWinInX", 2).toInt();
     limbInflationRatio = qSettings->value("limbInflationRatio", 1.1).toDouble();
     probToBinThresh = qSettings->value("probToBinThresh", 30).toInt();
     kNeirNeigh = qSettings->value("kNeirNeigh", 3).toInt();
 };

 void Settings::load() {
     qSettings->setValue("moviePath", moviePath);
     qSettings->setValue("dataPath", dataPath);
     qSettings->setValue("dataSet", dataSet);
     qSettings->setValue("cvWorkWinHight", cvWorkWinHight);
     qSettings->setValue("cvWorkWinInX", cvWorkWinInX);
     qSettings->setValue("limbInflationRatio", limbInflationRatio);
     qSettings->setValue("probToBinThresh", probToBinThresh);
     qSettings->setValue("kNeirNeigh", kNeirNeigh);

     haarFile = dataPath + "/storage/haarcascade_frontalface_alt.xml";
     minBlobSize = (cvWorkWinHight/10)*(cvWorkWinHight/10);
};
