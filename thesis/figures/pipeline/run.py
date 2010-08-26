#!/usr/bin/env python
'''
Created on Jul 13, 2010

@author: gijs
'''
#WORKSIZE = (640, 480)
WORKSIZE = (320, 240)
MINBLOB = (WORKSIZE[0]/20) * (WORKSIZE[1]/20)
BINS = 30

import cv
import sys

if len(sys.argv) == 2:
    filename = sys.argv[1]
else:
    filename = "input.jpg"

def sub_region((x, y, w, h)):

    xbor = 0.25 # 0.3
    ybor = 0.08 # 0.16
    x2 = x + w * xbor
    y2 = y + h * ybor
    w2 = w * (1.0-(2*xbor))
    h2 = h * (1.0-(2*ybor))
    return (int(x2), int(y2), int(w2), int(h2));


class Blob:
    def __init__(self, contour):
        self.contour = contour
        self.rect = cv.BoundingRect(contour)
        self.center = (self.rect[0] + self.rect[2]/2, self.rect[1] + self.rect[3]/2)
        self.area = self.rect[2] * self.rect[3]

# get frame
frame = cv.LoadImage(filename)

# resize frame
frameSmall = cv.CreateImage((640, 480), cv.IPL_DEPTH_8U, 3)
cv.Resize(frame, frameSmall)
frame = frameSmall

# create all other images
format = (frame.width,frame.height)
frameHSV = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
frameShow = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
frameCont = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
frameH = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameS = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameBW = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameBP = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameClosed = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameTh = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameBlur = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
frameSkinCut = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
temp = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)

# create histogram
hist = cv.CreateHist([BINS, BINS], cv.CV_HIST_ARRAY, [[0, 180], [0, 255]])

# calculate HSV and split
cv.CvtColor(frame, frameHSV, cv.CV_BGR2HSV)
cv.Split(frameHSV, frameH, frameS, frameBW, None)
cv.Copy(frame, frameShow)

# load face finder and find face
hc = cv.Load("/usr/local/share/opencv/haarcascades/haarcascade_frontalface_default.xml")
faces = cv.HaarDetectObjects(frameBW, hc, cv.CreateMemStorage())

if len(faces) == 0:
    print("can't find face")
    exit(1)


# draw face
faceRect = faces[0][0]
face_center = (faceRect[0] + faceRect[2]/2, faceRect[1] + faceRect[3]/2)
faceSubRect = sub_region(faceRect)
(x, y, w, h) = faceRect
cv.Rectangle(frameShow, (x,y), (x+w,y+h), cv.Scalar(0, 0, 255), 3)
(x, y, w, h) = faceSubRect
cv.Rectangle(frameShow, (x,y), (x+w,y+h), cv.Scalar(0, 255, 255), 3)

#calculate histogram
cv.SetImageROI(frameH, faceSubRect)
cv.SetImageROI(frameS, faceSubRect)
cv.CalcArrHist([frameH, frameS], hist, 0)

# turn this on or off:
#cv.NormalizeHist(hist, 1)
cv.NormalizeHist(hist, 5000)

cv.ResetImageROI(frameH)
cv.ResetImageROI(frameS)

#convert histogram to image
histImg = cv.GetMat(hist.bins, True)

#make backprojection
cv.CalcArrBackProject([frameH, frameS], frameBP, hist)

cv.Normalize(frameBP, frameBP, 0, 255, 32)
cv.Smooth( frameBP, frameBlur, param1=31);
cv.Threshold(frameBlur, frameTh, 30, 255, cv.CV_THRESH_BINARY);

# do morhphological close operation
dia=15
center=(dia/2)+1
element = cv.CreateStructuringElementEx(dia, dia, center, center, cv.CV_SHAPE_ELLIPSE)
#cv.MorphologyEx(frameTh, frameClosed, temp, element, cv.CV_MOP_CLOSE)
cv.Dilate(frameTh, frameClosed, element, 1)

# find contours
cv.Copy(frameClosed, temp)
contours = cv.FindContours(temp, cv.CreateMemStorage(),
    mode=cv.CV_RETR_EXTERNAL, method=cv.CV_CHAIN_APPROX_SIMPLE, offset=(0, 0))

contour_iter = contours

# label the contours
head = left = right = None
blobs = []
while contour_iter:
    blob = Blob(contour_iter)
    if cv.PointPolygonTest(contour_iter, face_center, 0) > 0:
        if head !=  None:
            print("ERROR: 2 heads found")
            exit(1)
        head = blob
    else:
        if blob.area > MINBLOB:
            blobs.append(blob)

    contour_iter = contour_iter.h_next()

blobs.sort(cmp=lambda x,y: cmp(x.area, y.area))
blobs = blobs[-2:]
blobs.sort(cmp=lambda x,y: cmp(x.center[0], y.center[0]))

n = len(blobs)
if n == 2:
    left = blobs[0]
    right = blobs[1]
elif n == 1:
    if blobs[0].center[0] < face_center[0]:
        left = blobs[0]
    else:
        right = blobs[0]
else:
    print("didn't find any limbs")


# draw contours and boundbingboxes
cv.Copy(frame, frameCont)
cv.ConvertScaleAbs(frameCont, frameCont, 0.2);
cv.Copy(frame, frameCont, frameClosed)
cv.DrawContours(img=frameCont, contour=contours,
    external_color=(50, 200, 50), hole_color=(50, 200, 50), max_level=1,
    thickness=1, lineType=1, offset=(0, 0))

if left:
    p1 = (left.rect[0], left.rect[1])
    p2 = (left.rect[0] + left.rect[2], left.rect[1] + left.rect[3])
    cv.Rectangle(frameCont, p1, p2, cv.Scalar(0, 255, 255), 3);
if right:
    p1 = (right.rect[0], right.rect[1])
    p2 = (right.rect[0] + right.rect[2], right.rect[1] + right.rect[3])
    cv.Rectangle(frameCont, p1, p2, cv.Scalar(0, 0, 255), 3);
if head:
    #cv.Rectangle(frameCont, head.rect, Scalar(0, 255, 255), 3);
    cv.Circle(frameCont, face_center, 3, cv.Scalar(255, 255, 255), 3);


# make left hand image
cv.Zero(frameSkinCut)
cv.Copy(frame, frameSkinCut, frameClosed)

leftHandImg = cv.CreateImage((left.rect[2], left.rect[3]), cv.IPL_DEPTH_8U, 3)
leftHandImgCut = cv.CreateImage((left.rect[2], left.rect[3]), cv.IPL_DEPTH_8U, 3)
leftHandImgBw = cv.CreateImage((left.rect[2], left.rect[3]), cv.IPL_DEPTH_8U, 1)
leftHandImgNorm = cv.CreateImage((left.rect[2], left.rect[3]), cv.IPL_DEPTH_8U, 1)
leftHandImgHog = cv.CreateImage((128, 128), cv.IPL_DEPTH_8U, 1)

cv.SetImageROI(frame, left.rect)
cv.Copy(frame, leftHandImg)
cv.ResetImageROI(frame)

cv.SetImageROI(frameSkinCut, left.rect)
cv.Copy(frameSkinCut, leftHandImgCut)
cv.ResetImageROI(frameSkinCut)


cv.CvtColor(leftHandImg ,leftHandImgBw, cv.CV_RGB2GRAY)

maxVal = cv.MinMaxLoc(leftHandImgBw)[1]
cv.ConvertScale(leftHandImgBw, leftHandImgBw, scale=255/maxVal)

cv.Resize(leftHandImgBw, leftHandImgHog)


f = open('histvals.txt', 'w')
# print histogram values
for x in range(histImg.width):
    for y in range(histImg.height):
        value = histImg[y, x] 
        f.write(str(value) + "\t")
    f.write("\n")
f.close()

# show images
cv.SaveImage("detected.jpg", frameShow)
cv.SaveImage("backproject.jpg", frameBP)
cv.SaveImage("blurred.jpg", frameBlur)
cv.SaveImage("thresholded.jpg", frameTh)
cv.SaveImage("closed.jpg", frameClosed)
cv.SaveImage("histogram.jpg", histImg)
cv.SaveImage("contours.jpg", frameCont)
cv.SaveImage("histogram.jpg", histImg)
cv.SaveImage("hue.jpg", frameH)
cv.SaveImage("saturation.jpg", frameS)
cv.SaveImage("value.jpg", frameBW)
cv.SaveImage("lefthand.jpg", leftHandImg)
cv.SaveImage("lefthandcutout.jpg", leftHandImgCut)
cv.SaveImage("lefthandhog.jpg", leftHandImgHog)



