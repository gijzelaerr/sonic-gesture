#include "audio.h"
#include <QDebug>

Audio::Audio() {
    connection = lo_address_new(NULL, "6666");
}

bool Audio::send(int left, int right, float leftPos, float rightPos) {
    //float scaledLeft = float(left+1)/29;
    //float scaledRight = float(right+1)/29;
    float scaledLeft = float(left+1);
    float scaledRight = float(right+1);

    if (lo_send(connection, "/sonicgesture/left","ff", scaledLeft, leftPos) == -1) {
        qDebug() << "OSC error " << lo_address_errno(connection) << ": " << lo_address_errstr(connection);
        return false;
    };
    if (lo_send(connection, "/sonicgesture/right","ff", scaledRight, rightPos) == -1) {
        qDebug() << "OSC error " << lo_address_errno(connection) << ": " << lo_address_errstr(connection);
        return false;
    };
    return true;
};
