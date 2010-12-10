/*!
 * \brief Output Open Sounc Control class.
 *
 * This class is used to transmit parameters to a OSC receiver.
 */


#include "audio.h"
#include <QDebug>

Audio::Audio() {
    connection = lo_address_new(NULL, "6666");
    triggerLeft = false;
    triggerRight = false;

    leftSizeAverage = 0.5;
    rightSizeAverage = 0.5;
}

bool Audio::send(int left, int right, float leftPos, float rightPos, float leftSize, float rightSize) {
    float scaledLeft = float(left+1)/12;
    float scaledRight = float(right+1)/12;

    //inverse y position
    leftPos =  1 - (1.5 * leftPos);
    rightPos = 1 - (1.5 * rightPos);

    leftSizeAverage += (leftSize - leftSizeAverage) * 0.1;
    rightSizeAverage += (rightSize - rightSizeAverage) * 0.1;

    lo_send(connection, "/sonicgesture/leftPos", "f", leftPos);
    lo_send(connection, "/sonicgesture/rightPos", "f", rightPos);

    //lo_send(connection, "/sonicgesture/leftSize", "f", leftSize);
    //lo_send(connection, "/sonicgesture/rightSize", "f", rightSizeAverage);

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
