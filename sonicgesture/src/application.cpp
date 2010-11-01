
#include "application.h"
#include <QtCore/QDebug>

Application::Application(int &c, char **v): QApplication(c, v){
};

bool Application::notify(QObject *rec, QEvent *ev) {
    try {
        return QApplication::notify(rec, ev);
    } catch (char const *str) {
        qDebug() << "EXCEPTION: " << str << endl;
        return false;
    } catch (...) {
        qDebug() << "Unknown exception!" << endl;
        return false;
        abort();
    }
};

