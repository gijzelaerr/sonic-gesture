
#include <Qt/QtGui>

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
        loadSource(Source(fileName.toStdString()));
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
    openAct = new QAction(QIcon(":open.png"), tr("&Open..."), this);
    openAct->setShortcuts(QKeySequence::Open);
    openAct->setStatusTip(tr("Open an existing file"));
    connect(openAct, SIGNAL(triggered()), this, SLOT(openFile()));

    aboutAct = new QAction(tr("About Sonic Gesture"), this);
    aboutAct->setStatusTip(tr("Show Sonic Gesture's About box"));
    connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));
};

void MainWindow::createMenus() {
    fileMenu = menuBar()->addMenu(tr("&File"));
    fileMenu->addAction(openAct);
    fileMenu->addSeparator();
    //fileMenu->addAction(exitAct);

    menuBar()->addSeparator();

    helpMenu = menuBar()->addMenu(tr("&Help"));
    helpMenu->addAction(aboutAct);
}

 void MainWindow::createToolBars() {
     fileToolBar = addToolBar(tr("File"));
     fileToolBar->addAction(openAct);
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

