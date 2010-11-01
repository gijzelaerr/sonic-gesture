/*!
 * \brief The mainwindow class
 *
 *  Connects the Logic with the GUI
 */

#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QtGui/QFileDialog>
#include <QtGui/QMessageBox>
#include <QtDebug>
#include <QKeyEvent>
#include <QTime>


MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    settings = Settings::getInstance();

    // make sure only ME gets keys
    grabKeyboard();

    startScreen();

    // initialize finder and capture, check if they start
    if (!finder.init(source.size) || !capture.init(source.size)) {
        QMessageBox::warning(this, tr("Can't initialize finder"), finder.error, QMessageBox::Ok);
    }

    whatWeSee = source.frame;
    ui->CVWindow->setImage(&whatWeSee);

    // set start flags
    viewMode = NORMAL;
    recMode = INPUT_;

    // call hearbeat to initialize image
    heartBeat();

}

MainWindow::~MainWindow() {
    delete ui;
    settings->destroy();
}


void MainWindow::openVideo() {
    QString fileName = QFileDialog::getOpenFileName(this, "Open Movie", settings->moviePath.path(),
            "Movies (*.asf *.mp4 *.mpeg *.wmv *.mpg *.mov *.avi *.jpg *.png *.jpeg)");
         if (!fileName.isEmpty()) {
            QFileInfo fileInfo(fileName);
            settings->moviePath = fileInfo.absolutePath();
            loadFile(fileName);
            this->setWindowTitle(QString("Sonic Gesture - %1").arg(fileInfo.fileName()));
        };
};


void MainWindow::loadFile(const QString &fileName) {
    source.close();
    if (!source.open(fileName)) {
        QMessageBox::warning(this, tr("Can't open file"), source.error, QMessageBox::Ok);
       return;
    }

    finder.init(source.size);
    capture.init(source.size);
    labeler.init(source.movieLocation);

    ui->actionOpen_Video->setChecked(true);
    ui->actionOpen_Device_2->setChecked(false);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(true);
    ui->positionSlider->setEnabled(true);
    ui->recordButton->setEnabled(true);



    videoState = PAUZE;
    stopRecord();

    // do one step so we see something on the screen
    step();
    ui->CVWindow->setImage(&whatWeSee);

    heartBeat();
}

void MainWindow::openDevice() {
    source.close();
    if (!source.open(settings->deviceId)) {
        QMessageBox::warning(this, tr("Can't open file"), source.error, QMessageBox::Ok);
        return;
    }

    this->setWindowTitle(QString("Sonic Gesture - device %1").arg(settings->deviceId));

    finder.init(source.size);
    capture.init(source.size);

    ui->actionOpen_Video->setChecked(false);
    ui->actionOpen_Device_2->setChecked(true);

    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
    ui->recordButton->setEnabled(true);
    videoState = PLAY;
    stopRecord();

    // do one step so we see something on the screen
    step();
    ui->CVWindow->setImage(&whatWeSee);

    heartBeat();
};

void MainWindow::startScreen() {
    stopRecord();
    source.startScreen();
    videoState = PLAY;
    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
    ui->recordButton->setEnabled(false);
    ui->actionOpen_Video->setChecked(false);
    ui->actionOpen_Device_2->setChecked(false);
    ui->positionSlider->setSliderPosition(0);

    // do one step so we see something on the screen
    //step();
    //ui->CVWindow->setImage(&whatWeSee);
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
    recMode = INPUT_;
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

    heartBeat();
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
    if (fileName.isEmpty()) {
        recording = false;
        ui->recordButton->setChecked(false);
        return;
    };

     if (!fileName.endsWith("avi"))
         fileName = fileName + ".avi";

     QFileInfo fileInfo(fileName);
     settings->moviePath = fileInfo.absoluteDir();
     if (!recorder.open(fileName,settings->FPS, whatWeSee.size()))
         QMessageBox::warning(this, tr("Can't save to file file"), tr("sorry, don't know why"), QMessageBox::Ok);
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
    if (!ui->positionSlider->isSliderDown()) {
        ui->positionSlider->setSliderPosition(position * ui->positionSlider->maximum());
    };
}

void MainWindow::heartBeat() {
    if (videoState == PAUZE)
        return;

    time.restart();
    step();
    int elapsed = time.elapsed();
    int MINWAIT = 4;
    int wait = (1000/settings->FPS) - elapsed;
    wait = MAX(wait, MINWAIT);
    //qDebug() << elapsed << "\t" << wait;
    QTimer::singleShot(wait, this, SLOT(heartBeat()));
};


void MainWindow::step() {
    if ((source.sourceMode == MOVIE) && (!ui->positionSlider->isSliderDown())) {
        setSliderPosition(source.getPos());
    }
    // if we can't grab, reset to test screen
    if (!source.grab()) {
        startScreen();
        return;
    }

    switch (viewMode) {
        case FINDER:
            finder.step(source.frame);
            whatWeSee = finder.combined;
            break;
        case CAPTURE:
            if (!capture.step(source.frame)) {
                if (source.sourceMode == MOVIE) {
                    pauze();
                } else {
                    startScreen();
                    sourceView();
                };
            };
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

    ui->CVWindow->update();
};


void MainWindow::closeEvent(QCloseEvent *event) {
};


void MainWindow::keyPressEvent(QKeyEvent* event) {
    event->accept();

    // if space is pressed
    if ((event->key() == 32)  && (viewMode == CAPTURE)) {
        // if we are in a movie
        if (source.sourceMode == MOVIE) {
            // add label, check if it is okay
            // TODO: don't add label during messagebox
            if (!labeler.add(source.getAbsolutePos())) {
               QMessageBox::warning(this, tr("Can't write label"), labeler.error, QMessageBox::Ok);
               return;
            }
        }

        if (!capture.saveImage()) {
            QMessageBox::warning(this, tr("Can't store image"), capture.error, QMessageBox::Ok);
            return;
        };
    };
};

void MainWindow::about() {
   QMessageBox::about(this, tr("About Sonic Gesture"),
          //tr("This is <b>Sonic Gesture</b>. More info at <a href=\"http://code.google.com/p/sonic-gesture/\">the website</a>")
                      tr("bla")
   );
}
