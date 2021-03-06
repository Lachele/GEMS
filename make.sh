#!/bin/bash
MOOD="$1"
TARGET_MAKE_FILE="Makefile-main"
echo $TARGET_MAKE_FILE
echo $MOOD
if [ -z "$PYTHON_HOME" ] ; then
	echo "PYTHON_HOME is not set.  Attempting to set it to /usr/include/python2.7 ..."
	if [ -e "/usr/include/python2.7/Python.h" ] ; then 
		export PYTHON_HOME="/usr/include/python2.7"
		echo "PYTHON_HOME has been set to /usr/include/python2.7."
	else
		echo "Cannot automatically set PYTHON_HOME environment variable.  Exiting."
		echo "Your PYTHON_HOME should be set to the location of Python.h for your python2.7 installation."
		exit 1
	fi
fi

cd gmml
if [ -f $TARGET_MAKE_FILE ]; then
	if [ "$MOOD" == "Qt" ]; then
		echo "Compile compatible with Qt"
		make distclean
		rm -rf gmml.pro*
		qmake -project -t lib -o gmml.pro "OBJECTS_DIR = build" "DESTDIR = bin"
		qmake -o
		make
	else
		echo "Qt independent compilation"
		make -f $TARGET_MAKE_FILE distclean
		rm -rf gmml.pro*
		make -f $TARGET_MAKE_FILE
	fi
else
	if [ "$MOOD" == "Qt" ]; then
		make distclean
		rm -rf gmml.pro*
		qmake -project -t lib -o gmml.pro "OBJECTS_DIR = build" "DESTDIR = bin"
		qmake -o
		make
	else
		echo "Qt independent make file does not exist"
	fi
fi
cd ..
if [ -f "gmml.i" ]; then
	swig -c++ -python gmml.i
else
	echo "Interface file for swig does not exist"
fi
PYTHON_FILE="$PYTHON_HOME/Python.h"
if [ -f $PYTHON_FILE ]; then
	if [ -f "gmml_wrap.cxx" ]; then
		g++ -O3 -fPIC -c gmml_wrap.cxx -I"$PYTHON_HOME"
	else
		echo "gmml_wrap.cxx does not exist"
	fi
else
	echo "PYTHON_HOME variable has not been set"
fi
if [ -f "gmml_wrap.o" ]; then
	g++ -shared gmml/build/*.o gmml_wrap.o -o _gmml.so
else
	echo "gmml has not been compiled correctly"
fi
