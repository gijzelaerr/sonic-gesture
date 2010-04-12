#ifndef _STABILIZER_H
#define	_STABILIZER_H

#define STATE_MAX 10
#define STATE_MIN 0
#define STATE_THRESH 8

#include <assert.h>

using namespace std;

class Stabilizer {
public:
    Stabilizer(int possibilities);
    void update(int state);
    int get_state();
    void set_callback();
private:
    trigger(bool active, int state);
    bool active;
    vector<int> states;
};

#endif	/* _STABILIZER_H */

