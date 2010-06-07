#include "audio.h"
#include <QDebug>

Audio::Audio() {
    connection = lo_address_new(NULL, "7770");
}

bool Audio::send() {
    const char testdata[] = "ABCDE";
    lo_blob btest = lo_blob_new(sizeof(testdata), testdata);

    if (lo_send(connection, "/quit", NULL) == -1)
        qDebug() << "OSC error " << lo_address_errno(connection) << ": " << lo_address_errstr(connection);

    if (lo_send(connection, "/foo/bar", "ff", 0.12345678f, 23.0f) == -1)
        qDebug() << "OSC error " << lo_address_errno(connection) << ": " << lo_address_errstr(connection);

    lo_send(connection, "/a/b/c/d", "sfsff", "one", 0.12345678f, "three", -0.00000023001f, 1.0);
    lo_send(connection, "/a/b/c/d", "b", btest);
    lo_send(connection, "/jamin/scene", "i", 2);
    return true;
};
