#ifndef _MAINWINDOW_H
#define _MAINWINDOW_H

#include <QtGui/QMainWindow>

#include "qcvimage.h"
#include "finder.h"
#include "capture.h"
#include "settings.h"
#include "recorder.h"


enum viewModeType { NORMAL, FINDER, CAPTURE };
enum sourceModeType { IMAGE, MOVIE, DEVICE };
enum recModeType { INPUT, OUTPUT };
enum videoStateType { RECORD, PLAY, PAUZE };

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
    Source source;
    Finder finder;
    Capture capture;
    Settings* settings;
    Recorder recorder;

    viewModeType viewMode;
    recModeType recMode;
    videoStateType videoState;
    sourceModeType sourceMode;

    QTimer* timer;

    Mat whatWeSee;


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
    void stopRecord();
    void startRecord();
    void heartBeat();
    void fullscreen();
    void setSliderPosition(int position);
};

#endif // MAINWINDOW_H
