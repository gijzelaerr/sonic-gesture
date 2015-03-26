# Introduction #

This page describes how to install Sonic Gesture. Currently only the latest Ubuntu or installation from source is supported.


# Ubuntu Installation #
There are prebuild Ubuntu Packages available! Use the following commands to install Sonic Gesture on Ubuntu 10.10:
```
 $ sudo add-apt-repository ppa:gijzelaar/sonicgesture
 $ sudo apt-get update
 $ sudo apt-get install sonicgesture
```

Now you can start Sonic Gesture from the menu under 'Sound & Video'

# Source Installation #
Follow these instructions if you want to compile the latest development version of Sonic Gesture from source.

## Requirements ##

You should install these packages with a package manager or compile them from source:

  * [cmake 2.0.8+](http://www.cmake.org)
  * [OpenCV 2.1+](http://opencv.willowgarage.com)
  * [Qt 4.6+](http://qt.nokia.com/downloads)
  * [Subversion](http://subversion.tigris.org/)
  * [Liblo](http://liblo.sourceforge.net/)
  * A compiler
  * Something that can understand OSC (optionally)

## Building ##

  * $ svn checkout https://sonic-gesture.googlecode.com/svn/trunk/sonic-gesture
  * $ cd sonic-gesture
  * $ mkdir build
  * $ cd build
  * $ cmake ..
  * $ make sonicgesture

## Running ##
This will result in a binary called sonicgesture. You can run this. Start your OSC program, and let it listen to port 6666. Go to finder mode. start doing gestures with your hand.