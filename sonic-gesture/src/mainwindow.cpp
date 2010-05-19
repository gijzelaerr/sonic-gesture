
#include <QtGui>

#include "mainwindow.h"
#include "qcvimage.h"

MainWindow::MainWindow() {
    cvImage = new QCVImage;
    setCentralWidget(cvImage);

     createActions();
     createMenus();
     createToolBars();
     createStatusBar();

     setUnifiedTitleAndToolBarOnMac(true);
}

void MainWindow::openFile() {
    QString fileName = QFileDialog::getOpenFileName(this);
    if (!fileName.isEmpty())
        loadSource(Source(fileName));
};

void MainWindow::openDevice() {
    int device = 0;
    loadSource(Source(device));
};

void MainWindow::loadSource(Source source) {
    cvImage->setSource(source);
}

void MainWindow::about() {
    QMessageBox::about(this, tr("About Sonic Gesture"),
            tr("This is Sonic Gesture."));
}

void MainWindow::createActions() {
    openFileAct = new QAction(QIcon(":film.png"), tr("&Open file..."), this);
    openFileAct->setShortcuts(QKeySequence::Open);
    openFileAct->setStatusTip(tr("Open a recorded movie"));
    connect(openFileAct, SIGNAL(triggered()), this, SLOT(openFile()));

    openDeviceAct = new QAction(QIcon(":camera.png"), tr("&Open device..."), this);
    openDeviceAct->setShortcuts(QKeySequence::Open);
    openDeviceAct->setStatusTip(tr("Open a device"));
    connect(openFileAct, SIGNAL(triggered()), this, SLOT(openDevice()));    
    
    aboutAct = new QAction(tr("About Sonic Gesture"), this);
    aboutAct->setStatusTip(tr("Show Sonic Gesture's About box"));
    connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));
};

void MainWindow::createMenus() {
    fileMenu = menuBar()->addMenu(tr("&File"));
    fileMenu->addAction(openFileAct);
    fileMenu->addAction(openDeviceAct);    
    fileMenu->addSeparator();
    //fileMenu->addAction(exitAct);

    menuBar()->addSeparator();

    helpMenu = menuBar()->addMenu(tr("&Help"));
    helpMenu->addAction(aboutAct);
}

 void MainWindow::createToolBars() {
     fileToolBar = addToolBar(tr("File"));
     fileToolBar->addAction(openFileAct);
     fileToolBar->addAction(openDeviceAct);
}

void MainWindow::createStatusBar() {
     statusBar()->showMessage(tr("Ready"));
}

void MainWindow::readSettings() {
    QSettings settings("Gijs Molenaar", "Sonic Gesture");
    QPoint pos = settings.value("pos", QPoint(200, 200)).toPoint();
    QSize size = settings.value("size", QSize(400, 400)).toSize();
    resize(size);
    move(pos);
}

void MainWindow::writeSettings() {
    QSettings settings("Gijs Molenaar", "Sonic Gesture");
    settings.setValue("pos", pos());
    settings.setValue("size", size());
}

int main(int argc, char *argv[]) {
    //Q_INIT_RESOURCE(application);

    QApplication app(argc, argv);
    app.setOrganizationName("Gijs Molenaar");
    app.setApplicationName("Sonic Gesture");
    MainWindow mainWin;
    mainWin.show();
    return app.exec();
}

