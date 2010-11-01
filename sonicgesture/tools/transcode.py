#!/usr/bin/env python

cores = 4
codec = "mjpeg"

import sys
import os
import subprocess
from multiprocessing import Pool


def transcode((source, destination)):
    cmd = ["/usr/bin/transcode", "-i", source, "-y" "ffmpeg", "-o", destination, "-F", codec]
    return subprocess.call(cmd)

def main():
    if len(sys.argv) != 2:
        print("usage: %s <dir with movies>" % sys.argv[0])
        sys.exit(1)

    moviedir=sys.argv[1]
    movies = [x for x in os.listdir(moviedir) if x.endswith('avi')]

    jobs = []
    for movie in movies:
        source = os.path.join(moviedir, movie)
        name = movie.split('.')[:-1]
        destionation = "small_" + movie
        jobs.append((source, destionation))

    results = map(transcode, jobs)
    #pool = Pool(processes=cores)
    #vals = pool.map(transcode, jobs, chunksize=1)


if __name__ == '__main__':
    main()
