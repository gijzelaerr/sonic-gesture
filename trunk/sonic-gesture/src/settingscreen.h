#ifndef SETTINGSSCREEN_H
#define SETTINGSSCREEN_H

#include <QWidget>
#include "ui_settingscreen.h"
#include "settings.h"



class SettingScreen : public QDialog { Q_OBJECT
public:
    SettingScreen(QWidget* parent = 0);

private:
    Ui::Dialog* ui;
    Settings* settings;
};

#endif // SETTINGSSCREEN_H
