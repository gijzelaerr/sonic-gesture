#include "audio.h"
#include <QDebug>

Audio::Audio() {
    connection = lo_address_new(NULL, "6666");
    triggerLeft = false;
    triggerRight = false;
}

bool Audio::send(int left, int right, float leftPos, float rightPos) {
    float scaledLeft = float(left+1)/28;
    float scaledRight = float(right+1)/28;

    lo_send(connection, "/sonicgesture/leftPos", "f", leftPos);
    lo_send(connection, "/sonicgesture/rightPos", "f", rightPos);

    if (left > -1) {
        if (!triggerLeft) {
            leftState = left;
            lo_send(connection, "/sonicgesture/LeftPitch", "f", scaledLeft);
            lo_send(connection, "/sonicgesture/leftTrigger", "f", 1.0);

        }
    } else {
        lo_send(connection, "/sonicgesture/leftTrigger", "f", 0.0);
    }


    if (right > -1) {
        if (!triggerRight) {
            rightState = right;
            lo_send(connection, "/sonicgesture/RightPitch", "f", scaledRight);
            lo_send(connection, "/sonicgesture/RightTrigger", "f", 1.0);
        }
    } else {
        lo_send(connection, "/sonicgesture/RightTrigger", "f", 0.0);
    }

};
