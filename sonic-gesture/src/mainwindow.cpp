#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QtGui/QFileDialog>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    source = new Source();
    ui->CVWindow->setSource(source);
}

MainWindow::~MainWindow() {
    delete ui;
    delete source;
}

void MainWindow::changeEvent(QEvent *e) {
    QMainWindow::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        ui->retranslateUi(this);
        break;
    default:
        break;
    }
}

void MainWindow::openVideo() {
    QString fileName = QFileDialog::getOpenFileName(this);
         if (!fileName.isEmpty()) {
             loadFile(fileName);
             ui->pauzeButton->setEnabled(true);
             ui->continueButton->setEnabled(false);
             ui->positionSlider->setEnabled(true);
         }
};

void MainWindow::loadFile(const QString &fileName) {
    source->open(fileName);
}

void MainWindow::openDevice() {
    source->open(0);
    ui->pauzeButton->setEnabled(false);
    ui->continueButton->setEnabled(false);
    ui->positionSlider->setEnabled(false);
};

void MainWindow::finderView() {
};

void MainWindow::captureView() {
};

void MainWindow::sourceView() {
};

void MainWindow::recordInput() {
};

void MainWindow::recordOutput() {
};

void MainWindow::pauze() {
};

void MainWindow::play() {
};

void MainWindow::changePosition() {
};

void MainWindow::startRecord() {

};
void MainWindow::stopRecord() {
    
};