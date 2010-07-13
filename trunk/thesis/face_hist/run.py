'''
Created on Jul 13, 2010

@author: gijs
'''

import cv
import sys

def sub_region((x, y, w, h)):

    xbor = 0.25 # 0.3
    ybor = 0.08 # 0.16
    x2 = x + w * xbor
    y2 = y + h * ybor
    w2 = w * (1.0-(2*xbor))
    h2 = h * (1.0-(2*ybor))
    return (int(x2), int(y2), int(w2), int(h2));


def main():
    frame = cv.LoadImage("face.jpg")
    format = (frame.width,frame.height)

    frameHSV = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
    frameShow = cv.CreateImage(format, cv.IPL_DEPTH_8U, 3)
    frameH = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
    frameS = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
    frameBW = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
    frameBP = cv.CreateImage(format, cv.IPL_DEPTH_8U, 1)
    hist = cv.CreateHist([30, 30], cv.CV_HIST_ARRAY, [[0, 180], [0, 255]], 1)
    
    cv.CvtColor(frame, frameHSV, cv.CV_BGR2HSV)
    cv.Split(frameHSV, frameH, frameS, frameBW, None)
    cv.Copy(frame, frameShow)
  
    hc = cv.Load("/usr/local/share/opencv/haarcascades/haarcascade_frontalface_default.xml")
    faceRect = cv.HaarDetectObjects(frameBW, hc, cv.CreateMemStorage())[0][0]

    faceSubRect = sub_region(faceRect)

    for (x, y, w, h)  in (faceRect, faceSubRect):
        cv.Rectangle(frameShow, (x,y), (x+w,y+h), 255)

    cv.SetImageROI(frameH, faceSubRect)
    cv.SetImageROI(frameS, faceSubRect)
    cv.CalcArrHist([frameH, frameS], hist, 0)
    #cv.NormalizeHist(hist, 255)
    cv.ResetImageROI(frameH)
    cv.ResetImageROI(frameS)
    
    cv.CalcArrBackProject([frameH, frameS], frameBP, hist)



    histImg = cv.GetMat(hist.bins, True)
    
    for x in range(histImg.width):
        for y in range(histImg.height):
            value = histImg[y, x] 
            sys.stdout.write(str(value) + "\t")
        sys.stdout.write("\n")



    #cv.ShowImage("face", frame)
    #cv.ShowImage("detected", frameShow)
    #cv.ShowImage("backproject", frameBP)
    #cv.ShowImage("Histogram", histImg)
    #cv.WaitKey()
    
    
    
if __name__ == '__main__':
    main()
