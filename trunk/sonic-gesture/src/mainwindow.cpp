#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QtGui/QFileDialog>
#include <QtGui/QMessageBox>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    settings = Settings::getInstance();
    source = new Source();
    finder = new Finder(source->size);
    capture = new Capture(source->size);
    whatWeSee = source->frame;
    ui->CVWindow->setImage(&whatWeSee);
    viewMode = NORMAL;
    recMode = OUTPUT;
    videoState = PLAY;
    sourceMode = IMAGE;
    
    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(heartBeat()));
    timer->start(25);
}

MainWindow::~MainWindow() {
    delete ui;
    delete source;
    delete finder;
    delete capture;
    delete settings;
}


void MainWindow::openVideo() {
    QDir bla;
    QString fileName = QFileDialog::getOpenFileName(this, "Open Movie", settings->moviePath.path(),
            "Movies (*.asf *.mp4 *.mpeg *.wmv *.mpg *.mov *.avi)");
         if (!fileName.isEmpty()) {
             settings->moviePath = bla.absoluteFilePath(fileName);
             loadFile(fileName);
         }
};


void MainWindow::loadFile(const QString &fileName) {
    source->open(fileName);
    finder->load(source->size);
    capture->load(source->size);

    ui->pauzeButton->setEnabled(true);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(true);

    sourceMode = MOVIE;
}

void MainWindow::openDevice() {
    source->open(0);
    finder->load(source->size);
    capture->load(source->size);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);

    sourceMode = DEVICE;
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
    videoState = PAUZE;
    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(true);
};

void MainWindow::play() {
    videoState = PLAY;
    ui->pauzeButton->setEnabled(true);
    ui->continueButton->setEnabled(false);
};

void MainWindow::changePosition() {
    double pos = (double)(ui->positionSlider->sliderPosition()) / ui->positionSlider->maximum();
    source->setPos(pos);
};

void MainWindow::record() {
};

void MainWindow::heartBeat() {
    if (videoState != PLAY)
        return;

    if ((sourceMode == MOVIE) && !ui->positionSlider->isSliderDown())
        ui->positionSlider->setSliderPosition(source->getPos() * ui->positionSlider->maximum());

    source->grab();
    switch (viewMode) {
        case FINDER:
            finder->step(source->frame);
            whatWeSee = finder->combined;
            break;
        case CAPTURE:
            capture->step(source->frame);
            whatWeSee = capture->combined;
            break;
        default:
            whatWeSee = source->frame;
            break;
    }
    ui->CVWindow->setImage(&whatWeSee);
    ui->CVWindow->update();
}

void MainWindow::closeEvent(QCloseEvent *event) {
};

