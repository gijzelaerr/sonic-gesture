import sys
from cv import *

def inside(r, q):
    (rx, ry), (rw, rh) = r
    (qx, qy), (qw, qh) = q
    return rx > qx and ry > qy and rx + rw < qx + qw and ry + rh < qy + qh

NamedWindow("people detection demo", 1)
storage = CreateMemStorage(0)
capture = CaptureFromCAM(-1)
small = CreateImage((320, 240), 8, 3)


while True:
    orig = QueryFrame(capture)
    PyrDown(orig, small)
    #ClearMemStorage(storage)
    found = list(HOGDetectMultiScale(small, storage, win_stride=(8,8),
        padding=(32,32), scale=1.05, group_threshold=2))
    found_filtered = []
    for r in found:
        insidef = False
        for q in found:
            if inside(r, q):
                insidef = True
                break
        if not insidef:
            found_filtered.append(r)
    for r in found_filtered:
        (rx, ry), (rw, rh) = r
        tl = (rx + int(rw*0.1), ry + int(rh*0.07))
        br = (rx + int(rw*0.9), ry + int(rh*0.87))
        Rectangle(small, tl, br, (0, 255, 0), 3)
        
    ShowImage("people detection demo", small)
    c = WaitKey(2)
    if c == ord('q'):
        break
