#include "settingsscreen.h"
#include "settings.h"
#include <QtDebug>



SettingsScreen::SettingsScreen(QWidget *parent) : QDialog(parent), ui(new Ui::Dialog) {
    ui->setupUi(this);
    settings = Settings::getInstance();
};
