#ifndef SETTINGSSCREEN_H
#define SETTINGSSCREEN_H

#include <QWidget>
#include "ui_settingscreen.h"
#include "settings.h"



class SettingsScreen : public QDialog { Q_OBJECT
public:
    SettingsScreen(QWidget* parent = 0);
    ~SettingsScreen();

private:
    Ui::Dialog* ui;
    Settings* settings;
};

#endif // SETTINGSSCREEN_H
