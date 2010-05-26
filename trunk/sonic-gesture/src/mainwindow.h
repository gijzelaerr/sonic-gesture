#ifndef _MAINWINDOW_H
#define _MAINWINDOW_H

#include <QtGui/QMainWindow>

#include "qcvimage.h"
#include "finder.h"
#include "capture.h"
#include "settings.h"


enum viewModeType { NORMAL, FINDER, CAPTURE };
enum sourceModeType { IMAGE, MOVIE, DEVICE };
enum recModeType { INPUT, OUTPUT };
enum videoStateType { PLAY, PAUZE };

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
    videoStateType videoState;
    sourceModeType sourceMode;
    QTimer* timer;
    Mat whatWeSee;
    Finder* finder;
    Capture* capture;
    Settings* settings;

 protected:
     void closeEvent(QCloseEvent *event);

private slots:
    void loadFile(const QString &fileName);
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
