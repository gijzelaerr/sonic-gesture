#include "audio.h"
#include <QDebug>

Audio::Audio() {
    connection = lo_address_new(NULL, "6666");
}

bool Audio::send(int left, int right, float leftPos, float rightPos) {
    if (lo_send(connection, "/sonicgesture","iiff", left, right, leftPos, rightPos) == -1) {
        qDebug() << "OSC error " << lo_address_errno(connection) << ": " << lo_address_errstr(connection);
        return false;
    };
    return true;
};
