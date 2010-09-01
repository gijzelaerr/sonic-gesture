#ifndef AUDIO_H
#define AUDIO_H

#include "lo/lo.h"

class Audio {
public:
    Audio();
    bool send(int left, int right, float leftPos, float rightPos, float leftSize, float rightSize);

    float leftState;
    float rightState;
    bool triggerLeft;
    bool triggerRight;

private:
    lo_address connection;
};

#endif // AUDIO_H
