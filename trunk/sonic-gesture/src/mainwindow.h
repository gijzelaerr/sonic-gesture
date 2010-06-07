#ifndef _MAINWINDOW_H
#define _MAINWINDOW_H

#include <QtGui/QMainWindow>

#include "qcvimage.h"
#include "finder.h"
#include "capture.h"
#include "settings.h"
#include "recorder.h"
#include "source.h"
#include "labeler.h"


enum ViewModeType { NORMAL, FINDER, CAPTURE };
enum RecModeType { INPUT_, OUTPUT };
enum VideoStateType { PLAY, PAUZE };

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
    Labeler labeler;


    ViewModeType viewMode;
    RecModeType recMode;
    VideoStateType videoState;
    SourceModeType sourceMode;
    bool recording;

    QTimer* timer;

    Mat whatWeSee;

    void step();
    void stopRecord();
    void startRecord();
    void startScreen();

 protected:
     void closeEvent(QCloseEvent* event);
     void keyPressEvent(QKeyEvent* event);

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
    void fullscreen();
    void setSliderPosition(double position);
};

#endif // MAINWINDOW_H
