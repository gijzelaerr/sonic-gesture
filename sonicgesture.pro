


# where to put resulting binary
DESTDIR = $${PWD}/result

macx {
    CONFIG += app_bundle
}

ICON = $${PWD}/sonicgesture.icns

QT       += core gui


CONFIG(debug, debug|release) {
    TARGET = sonicgesture-debug
} else {
    TARGET = sonicgesture
}



TEMPLATE = app


INCLUDEPATH += \
    C:/dev/MinGW/msys/1.0/local/include \
    src


SOURCES += \
    src/qcvimage.cpp \
    src/finder.cpp \
    src/skinfinder.cpp \
    src/source.cpp  \
    src/histogram.cpp  \
    src/combiner.cpp  \
    src/tools.cpp \
    src/settings.cpp \
    src/bodypart.cpp \
    src/blob.cpp \
    src/matcher.cpp \
    src/loader.cpp \
    src/main.cpp \
    src/mainwindow.cpp \
    src/application.cpp \
    src/recorder.cpp \
    src/labeler.cpp \
    src/audio.cpp \
    src/matwidget.cpp


HEADERS += \
    src/qcvimage.h \
    src/finder.h \
    src/skinfinder.h \
    src/source.h  \
    src/histogram.h  \
    src/combiner.h  \
    src/tools.h \
    src/settings.h \
    src/bodypart.h \
    src/blob.h \
    src/matcher.h \
    src/loader.h \
    src/mainwindow.h \
    src/application.h \
    src/recorder.h \
    src/labeler.h \
    src/audio.h \
    src/matwidget.h


FORMS    += qt/mainwindow.ui


RESOURCES += qt/resources.qrc


win32:INCLUDEPATH += \
    include \


win32:LIBS += \
    -L$${PWD}/lib \
    -LC:\dev\MinGW\msys\1.0\local\lib \
    -lml210 \
    -lcv210 \
    -lcvaux210 \
    -lcxcore210 \
    -lhighgui210 \
    -lopencv_ffmpeg210 \
    -llo \
    -lpthread \
    -lws2_32 \
    -lwsock32

macx:LIBS += \
    -llo \
    -lopencv_core \
    -lopencv_highgui \
    -lopencv_imgproc \
    -lopencv_ml \
    -lopencv_objdetect \
    -lopencv_video
