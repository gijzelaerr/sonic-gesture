#!/usr/bin/env python

FPS=10
WIDTH=640
HEIGHT=480

import sys
import os
import cv


if len(sys.argv) != 4:
    print "use this te create movie of images\n"
    print "usage: %s <image folder> <output movie> <showtime>\n" % sys.argv[0]
    sys.exit(1)

image_folder = sys.argv[1]
output_movie = sys.argv[2]
showtime = int(sys.argv[3])


if not os.access(image_folder, os.X_OK):
    print "can't acess %s" % image_folder
    sys.exit(1)


writer = cv.CreateVideoWriter(output_movie, cv.CV_FOURCC('M','J','P','G'), FPS, (WIDTH,HEIGHT), True) 
sized = cv.CreateImage((WIDTH, HEIGHT), cv.IPL_DEPTH_8U, 3)

for f in [x for x in os.listdir(image_folder) if not x.startswith('.')]:
    p = os.path.join(image_folder, f)
    print "loading", p
    frame = cv.LoadImage(p)
    cv.Resize(frame, sized)
    for i in range(FPS*showtime):
        print cv.WriteFrame(writer, sized)

