#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QtGui/QFileDialog>
#include <QtGui/QMessageBox>
#include <QtDebug>
#include <QKeyEvent>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    settings = Settings::getInstance();

    // make sure only ME gets keys
    grabKeyboard();

    startScreen();
    finder.init(source.size);
    capture.init(source.size);
    whatWeSee = source.frame;

    ui->CVWindow->setImage(&whatWeSee);

    // set start flags
    viewMode = NORMAL;
    recMode = OUTPUT;

    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(heartBeat()));
    timer->start(1000/settings->FPS);
}

MainWindow::~MainWindow() {
    delete ui;
    settings->destroy();
}


void MainWindow::openVideo() {
    QString fileName = QFileDialog::getOpenFileName(this, "Open Movie", settings->moviePath.path(),
            "Movies (*.asf *.mp4 *.mpeg *.wmv *.mpg *.mov *.avi)");
         if (!fileName.isEmpty()) {
            QFileInfo fileInfo(fileName);
            settings->moviePath = fileInfo.absolutePath();
            loadFile(fileName);
         }
};


void MainWindow::loadFile(const QString &fileName) {

    if (!source.open(fileName)) {
        QMessageBox::warning(this, tr("Can't open file"), source.lastError(), QMessageBox::Ok);
       return;
    }

    finder.init(source.size);
    capture.init(source.size);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(true);
    ui->positionSlider->setEnabled(true);
    ui->recordButton->setEnabled(true);

    videoState = PAUZE;
    sourceMode = MOVIE;
    stopRecord();
    step();
}

void MainWindow::openDevice() {
    if (!source.open(0)) {
        QMessageBox::warning(this, tr("Can't open file"), source.lastError(), QMessageBox::Ok);
        return;
    }

    finder.init(source.size);
    capture.init(source.size);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
    ui->recordButton->setEnabled(true);
    videoState = PLAY;
    stopRecord();
    sourceMode = DEVICE;
};

void MainWindow::startScreen() {
    stopRecord();
    source = Source();
    videoState = PLAY;
    sourceMode = IMAGE;
    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
    ui->recordButton->setEnabled(false);
}

void MainWindow::finderView() {
    viewMode = FINDER;
    ui->actionFinder_View->setChecked(true);
    ui->actionCapture_View->setChecked(false);
    ui->actionSource_view->setChecked(false);
    step();
};

void MainWindow::captureView() {
    viewMode = CAPTURE;
    ui->actionFinder_View->setChecked(false);
    ui->actionCapture_View->setChecked(true);
    ui->actionSource_view->setChecked(false);
    step();
};

void MainWindow::sourceView() {
    viewMode = NORMAL;
    ui->actionFinder_View->setChecked(false);
    ui->actionCapture_View->setChecked(false);
    ui->actionSource_view->setChecked(true);
    step();
};

void MainWindow::recordInput() {
    recMode = INPUT;
    ui->actionRecord_original_movie->setChecked(true);
    ui->actionRecord_visual_output->setChecked(false);
};

void MainWindow::recordOutput() {
    recMode = OUTPUT;
    ui->actionRecord_original_movie->setChecked(false);
    ui->actionRecord_visual_output->setChecked(true);
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
    source.setPos(pos);
};

void MainWindow::record() {
    if (recording) {
        stopRecord();
    } else {
       startRecord();
    };
};

void MainWindow::stopRecord() {
    ui->recordButton->setChecked(false);
    recorder = Recorder();
    recording = false;

}

void MainWindow::startRecord() {
    QString fileName = QFileDialog::getSaveFileName(this, "Record Movie",
              settings->moviePath.path(), "Movies (*.avi)");
     if (fileName.isEmpty())
        return;

     if (!fileName.endsWith("avi"))
         fileName = fileName + ".avi";

     QFileInfo fileInfo(fileName);
     settings->moviePath = fileInfo.absoluteDir();
     recorder = Recorder(fileName,settings->FPS, whatWeSee.size());
     ui->recordButton->setChecked(true);
     recording = true;
};

void MainWindow::fullscreen() {
    bool status = ui->actionFullscreen->isChecked();

    if(status) {
        ui->actionFullscreen->setChecked(true);
        this->showFullScreen();
    } else {
        ui->actionFullscreen->setChecked(false);
        this->showNormal();
    }
}

void MainWindow::setSliderPosition(double position) {
    ui->positionSlider->setSliderPosition(position * ui->positionSlider->maximum());
}

void MainWindow::heartBeat() {
    if (videoState == PAUZE)
        return;

    step();
};


void MainWindow::step() {
    if ((sourceMode == MOVIE) && (!ui->positionSlider->isSliderDown())) {
        setSliderPosition(source.getPos());
    }
    // if we can't grab, reset to test screen
    if (!source.grab()) {
        startScreen();
    }

    switch (viewMode) {
        case FINDER:
            finder.step(source.frame);
            whatWeSee = finder.combined;
            break;
        case CAPTURE:
            capture.step(source.frame);
            whatWeSee = capture.combined;
            break;
        default:
            whatWeSee = source.frame;
            break;
    };

    if (recording) {
        if (recMode == OUTPUT) {
            recorder.putFrame(whatWeSee);
        } else {
            recorder.putFrame(source.frame);
        };
    };

    ui->CVWindow->setImage(&whatWeSee);
};

void MainWindow::closeEvent(QCloseEvent *event) {
};

void MainWindow::keyPressEvent(QKeyEvent* event) {
    event->accept();

    // if space is pressed
    if ((event->key() == 32)  && (viewMode == CAPTURE)) {
        qDebug() << source.getAbsolutePos() << "# action";
        if (!capture.saveImage()) {
            QMessageBox::warning(this, tr("Can't store image"), capture.error, QMessageBox::Ok);
        };
    };
};
