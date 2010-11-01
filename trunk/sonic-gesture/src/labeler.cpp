/*!
 * \brief Stores labels capture with the 'capture' mode into a label file
 *
  */
#include "labeler.h"

#include <QString>
#include <QFileInfo>
#include <QStringList>
#include <QTextStream>
#include <QDebug>

Labeler::Labeler() {
    labelFile = NULL;
};

Labeler::~Labeler() {
    close();
};

void Labeler::close() {
    if (labelFile != NULL && labelFile->isOpen()) {
        labelFile->close();
        delete labelFile;
    };
};

bool Labeler::init(QFileInfo& movie) {
    close();
    first = true;
    QString where = movie.path();
    QString movieName = movie.fileName();
    QStringList split = movieName.split(".");
    split.removeLast();
    labelFileInfo = QFileInfo(where + "/" + split.join(".") + "_labels.txt");
    this->labelFile = new QFile(labelFileInfo.filePath());
    return true;

}

bool Labeler::add(double moment) {
    double pos = source.getAbsolutePos();

    if(first) {
        if (labelFileInfo.exists()) {
            setError(QString("label file (%1) already exists").arg(labelFileInfo.filePath()));
            return false;
        };

        if (!labelFile->open(QIODevice::WriteOnly | QIODevice::Text)) {
            setError(labelFile->errorString());
            return false;
        };
        first = false;
    };

    QTextStream out(labelFile);
    out << moment << "\n";
    return true;

}


void Labeler::setError(QString error) {
    qDebug() << error;
    this->error = error;
}
