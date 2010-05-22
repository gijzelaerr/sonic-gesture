#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QtGui/QFileDialog>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    source = new Source();
    finder = Finder(source->size);
    capture = Capture(source->size);
    whatWeSee = source->frame;
    ui->CVWindow->setImage(&whatWeSee);
    viewMode = NORMAL;
    recMode = OUTPUT;
    
    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(heartBeat()));
    timer->start(25);

    readSettings();
}

MainWindow::~MainWindow() {
    delete ui;
    delete source;
}


void MainWindow::openVideo() {
    QDir bla;
    QString fileName = QFileDialog::getOpenFileName(this, "Open Movie", moviePath, "Movies (*.asf *.mp4 *.mpeg *.wmv *.mpg *.mov *.avi)");
         if (!fileName.isEmpty()) {
             moviePath = bla.absoluteFilePath(fileName);
             loadFile(fileName);
         }
};


void MainWindow::loadFile(const QString &fileName) {
    source->open(fileName);
    finder = Finder(source->size);
    capture = Capture(source->size);

    ui->pauzeButton->setEnabled(true);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(true);

}

void MainWindow::openDevice() {
    source->open(0);
    finder = Finder(source->size);
    capture = Capture(source->size);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
};

void MainWindow::finderView() {
    viewMode = FINDER;
    ui->actionFinder_View->setChecked(true);
    ui->actionCapture_View->setChecked(false);
    ui->actionSource_view->setChecked(false);
};

void MainWindow::captureView() {
    viewMode = CAPTURE;
    ui->actionFinder_View->setChecked(false);
    ui->actionCapture_View->setChecked(true);
    ui->actionSource_view->setChecked(false);
};

void MainWindow::sourceView() {
    viewMode = NORMAL;
    ui->actionFinder_View->setChecked(false);
    ui->actionCapture_View->setChecked(false);
    ui->actionSource_view->setChecked(true);
};

void MainWindow::recordInput() {
    recMode = INPUT;
    ui-> actionRecord_original_movie->setChecked(true);
    ui-> actionRecord_visual_output->setChecked(false);
};

void MainWindow::recordOutput() {
    recMode = OUTPUT;
    ui-> actionRecord_original_movie->setChecked(false);
    ui-> actionRecord_visual_output->setChecked(true);
};

void MainWindow::pauze() {
};

void MainWindow::play() {
};

void MainWindow::changePosition() {
};

void MainWindow::record() {
};

void MainWindow::heartBeat() {
    source->grab();
    switch (viewMode) {
        case FINDER:
            finder.step(source->frame);
            whatWeSee = finder.combined;
            ui->CVWindow->setImage(&whatWeSee);
            break;
        case CAPTURE:
            capture.step(source->frame);
            whatWeSee = capture.combined;
            ui->CVWindow->setImage(&whatWeSee);
            break;
        default:
            whatWeSee = source->frame;
            break;
    }
    imshow("testje", whatWeSee);
    waitKey(40);
    ui->CVWindow->update();
}

void MainWindow::closeEvent(QCloseEvent *event) {
    writeSettings();
}

 void MainWindow::readSettings()  {
     QSettings settings("Gijs Molenaar", "Sonic Gesture");
     moviePath = settings.value("moviePath", ".").toString();
 }

 void MainWindow::writeSettings() {
     QSettings settings("Gijs Molenaar", "Sonic Gesture");
     settings.setValue("moviePath", moviePath);
 }