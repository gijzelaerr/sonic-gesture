#ifndef LABELER_H
#define LABELER_H

#include "source.h"
#include <QString>

class Labeler
{
public:
    Labeler();
    ~Labeler();

    bool init(QFileInfo& movie);
    bool add(double moment);
    QString error;

private:
    void setError(QString error);
    QFile* labelFile;
    QFileInfo labelFileInfo;
    bool first;
    Source source;

};

#endif // LABELER_H
