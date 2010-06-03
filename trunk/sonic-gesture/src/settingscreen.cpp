#include "settingscreen.h"
#include "settings.h"
#include <QtDebug>



SettingScreen::SettingScreen(QWidget *parent) : QDialog(parent), ui(new Ui::Dialog) {
    ui->setupUi(this);
    settings = Settings::getInstance();
};
