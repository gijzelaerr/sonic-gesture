#ifndef _STABILIZER_H
#define	_STABILIZER_H

#define STATE_MAX 10
#define STATE_MIN 0
#define STATE_THRESH 8

#include <assert.h>
#include <vector>

using namespace std;

class Stabilizer {
public:
    Stabilizer(int state_num=1);
    int update(int state);
    int get_state();
    void set_callback();
    bool is_active();
private:
    void trigger(bool active, int state);
    bool active;
    vector<int> states;
};

#endif	/* _STABILIZER_H */

