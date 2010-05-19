#ifndef _MAINWINDOW_H
#define	_MAINWINDOW_H

#include <QtGui/QMainWindow>
#include "source.h"

class QAction;
class QMenu;
class QCVImage;

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow();

private slots:
    void openFile();
    void openDevice();
    void about();

private:
    void createActions();
    void createMenus();
    void createToolBars();
    void createStatusBar();
    void readSettings();
    void writeSettings();
    void loadSource(Source source);


    QCVImage* cvImage;

    QMenu *fileMenu;
    QMenu *settingsMenu;
    QMenu *helpMenu;

    QToolBar *fileToolBar;
    QToolBar *settingsToolBar;

    QAction *openFileAct;
    QAction *openDeviceAct;
    QAction *exitAct;
    QAction *aboutAct;
    QAction *aboutQtAct;
};


#endif

