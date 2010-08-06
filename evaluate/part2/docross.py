#!/usr/bin/env python

performance='../../sonic-gesture/qtcreator-build/performance'
trainset='../../sonic-gesture/data/sets/all/train'
movies='../../sonic-gesture/data/movies/transcoded'
output='labels'
tmp='tmp'


import os
import sys
import subprocess


assert(os.access(performance, os.X_OK))
assert(os.access(trainset, os.X_OK))
assert(os.access(movies, os.X_OK))
assert(os.access(output, os.X_OK))
assert(os.access(tmp, os.X_OK))

for movie in [x for x in os.listdir(movies) if x.endswith('.avi')]:
    name = movie.split('.')[0]
    print "processing name"
    testset = os.path.join(trainset, name)
    assert(os.access(testset, os.X_OK))
    target = os.path.join(tmp, name)
    print "renaming %s to %s" % (testset, target)
    os.rename(testset, target)
    f = open(os.path.join(output, name + '_labels.txt'), 'w')
    cmd = [performance, os.path.join(movies, movie)]
    print "running %s" % " ".join(cmd)
    p = subprocess.Popen(cmd, stdout=f)
    p.wait()
    f.close()
    print "renaming %s to %s" % (target, testset)
    os.rename(target, testset)
