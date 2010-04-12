
#include <vector>

#include "stabilizer.h"

Stabilizer::Stabilizer(int state_num) {
    this->states = vector();
    for (int i = 0; i < state_num; i++) {
        this->states.push_back(STATE_MIN);
    }
};

// update stabilizer with new measurement. Decrease all non-measured states
void Stabilizer::update(int state) {
    assert(state <= this->states.size());
    int new;

    for (unsigned int i = 0; i < this->states.size(); i++) {
        if (i == state) {
            new = min(this->states.at(i)+1, STATE_MAX);
            this->states.at(i) = new;
            if (new >= STATE_THRESH && !this->active) {
                this->trigger(true, i);
            }
        } else {
            new = max(this->states.at(i)-1, STATE_MIN);
            this->states.at(i) = new;
            if (new < STATE_THRESH && this->active) {
                this->trigger(false, i);
            }
        }
    }
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
    return max_state;
};

void Stabilizer::trigger(bool new_active, int new_state) {
    
}

void Stabilizer::set_callback() {

};


