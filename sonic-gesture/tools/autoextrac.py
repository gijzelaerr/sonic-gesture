#!/usr/bin/env python

import os
import sys
import subprocess

here = os.path.dirname(__file__)

if len(sys.argv) != 3:
    print "usage: %s <extractor path> <dir_with_movies>" % sys.argv[0]
    sys.exit(1)
else:
    extractor = sys.argv[1]
    moviedir = sys.argv[2]

if not os.access(extractor, os.X_OK):
    raise Exception("extractor not found: %s" % extractor)

if not os.access(moviedir, os.X_OK):
    raise Exception("moviedir not found: %s" % moviedir)


movies = [x for x in os.listdir(moviedir) if x.endswith('.avi')]

if len(movies) == 0:
    print "no movies in %s" % moviedir
    sys.exit(1)

for movie in movies:
    session = movie.split('.')[0]
    labels = session + '_labels.txt'
    output_path = os.path.join(moviedir, session)
    movie_path = os.path.join(moviedir, movie)
    labels_path = os.path.join(moviedir, labels)

    if not os.access(movie_path, os.R_OK):
        raise Exception("can't access %s" % movie_path)

    if not os.access(labels_path, os.R_OK):
        raise Exception("can't access %s" % labels_path)

    if os.access(output_path, os.F_OK):
        print("%s already exists, skipping" % output_path) 
        continue

    print("doing %s" % movie)
    retcode = subprocess.call([extractor, movie_path, labels_path, output_path])

