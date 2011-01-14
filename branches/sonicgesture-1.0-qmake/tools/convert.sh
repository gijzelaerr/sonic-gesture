#!/bin/bash

chmod 644 sonicgesture.app/Contents/Frameworks/*.dylib
install_name_tool -id @executable_path/../Frameworks/liblo.7.dylib sonicgesture.app/Contents/Frameworks/liblo.7.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_core.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_core.2.2.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_imgproc.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_imgproc.2.2.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_objdetect.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_objdetect.2.2.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_highgui.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_highgui.2.2.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_ml.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_ml.2.2.dylib
install_name_tool -id @executable_path/../Frameworks/libopencv_video.2.2.dylib sonicgesture.app/Contents/Frameworks/libopencv_video.2.2.dylib

p="/usr/local/Cellar/opencv/2.2.1-svn4437/lib/"
q="sonicgesture.app/Contents/Frameworks/"
for i in `ls ${q}*.dylib | xargs -n1 basename`; do
	for j in `ls ${p}libopencv_*  | xargs -n1 basename`; do
		 install_name_tool -change ${p}${j} @executable_path/../Frameworks/${j} ${q}${i}
	done
done

install_name_tool -id @executable_path/../Frameworks/QtNetwork.framework/Versions/4/QtNetwork sonicgesture.app/Contents/Frameworks/QtNetwork.framework/Versions/4/QtNetwork
install_name_tool -id @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore sonicgesture.app/Contents/Frameworks/QtCore.framework/Versions/4/QtCore
install_name_tool -id @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui sonicgesture.app/Contents/Frameworks/QtGui.framework/Versions/4/QtGui

for i in `ls sonicgesture.app/Contents/Frameworks/*.framework/Versions/4/*`; do
	chmod 644 ${i}
	install_name_tool -change /usr/local/Cellar/qt/4.7.1/lib/QtCore.framework/Versions/4/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore ${i}
	install_name_tool -change /usr/local/Cellar/qt/4.7.1/lib/QtGui.framework/Versions/4/QtGui @executable_path/../Frameworks/QtCore.framework/Versions/4/QtGui ${i}
	install_name_tool -change /usr/local/Cellar/qt/4.7.1/lib/QtNetwork.framework/Versions/4/QtNetwork @executable_path/../Frameworks/QtNetwork.framework/Versions/4/QtNetwork ${i}
done