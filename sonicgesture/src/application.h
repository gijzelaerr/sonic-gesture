#ifndef _APPLICATION_H
#define	_APPLICATION_H

#include <QtGui/QApplication>

class Application: public QApplication {
   Q_OBJECT;
public:
   Application(int &c, char **v);
   bool notify(QObject *rec, QEvent *ev);
};

#endif	/* _APPLICATION_H */

