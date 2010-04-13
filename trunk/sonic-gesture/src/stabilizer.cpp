
#include <vector>
#include <iostream>
#include "stabilizer.h"

using namespace std;

Stabilizer::Stabilizer(int state_num) {
    for (int i = 0; i < state_num; i++) {
        this->states.push_back(STATE_MIN);
    }
};

Stabilizer::~Stabilizer() {
};


// update stabilizer with new measurement. Decrease all non-measured states
int Stabilizer::update(int state) {
    assert(state <= (int)this->states.size());
    int new_val;

    for (int i = 0; i < (int)this->states.size(); i++) {
        if (i == state) {
            new_val = min(this->states.at(i)+1, STATE_MAX);
            this->states.at(i) = new_val;
            //cout << "update " << i << " with " << new_val;
            if ((new_val >= STATE_THRESH) && (!this->active)) {
                this->trigger(true, i);
            }
        } else {
            new_val = max(this->states.at(i)-1, STATE_MIN);
            this->states.at(i) = new_val;
            if ((new_val < STATE_THRESH) && (this->active)) {
                this->trigger(false, i);
            }
        }
    }
    return this->get_state();
};

// return num of max state
int Stabilizer::get_state() {
    int max_val = -1;
    int val, max_state;

    for (unsigned int i = 0; i < this->states.size(); i++) {
        val = this->states.at(i);
        if (val > max_val) {
            max_state = i;
            max_val = val;
        }
    }
    if (max_val > STATE_THRESH) {
        return max_state;
    } else {
        return -1;
    }
};

void Stabilizer::trigger(bool new_active, int new_state) {
    this->active = new_active;
}

bool Stabilizer::is_active() {
    return this->active;
}

void Stabilizer::set_callback() {

};


