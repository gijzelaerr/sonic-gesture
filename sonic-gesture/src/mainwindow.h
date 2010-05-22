#ifndef _MAINWINDOW_H
#define _MAINWINDOW_H

#include <QtGui/QMainWindow>

#include "qcvimage.h"
#include "finder.h"
#include "capture.h"


enum viewModeType { NORMAL, FINDER, CAPTURE };
enum recModeType { INPUT, OUTPUT };

namespace Ui {
    class MainWindow;
}

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    MainWindow(QWidget* parent = 0);
    ~MainWindow();

private:
    Ui::MainWindow* ui;
    Source* source;
    viewModeType viewMode;
    recModeType recMode;
    QTimer* timer;
    Mat whatWeSee;
    QString moviePath;
    Finder finder;
    Capture capture;
    
    void loadFile(const QString &fileName);
    void readSettings();
    void writeSettings();

 protected:
     void closeEvent(QCloseEvent *event);

private slots:
    void openVideo();
    void openDevice();
    void finderView();
    void captureView();
    void sourceView();
    void recordInput();
    void recordOutput();
    void pauze();
    void play();
    void changePosition();
    void record();
    void heartBeat();
};

#endif // MAINWINDOW_H
