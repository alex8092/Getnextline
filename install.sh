#!/bin/sh

set -e

PREFIX=/usr

if [ ! -w $PREFIX/lib ] || [ ! -w $PREFIX/include ];
then
	PREFIX=~/.ft
fi

if [ ! -z $4 ] && [ "$4" = "uninstall" ];
then
	echo "Uninstall in prefix : $PREFIX"
	echo "Removing librarys ..."
	rm -f $PREFIX/$1
	echo "Removing includes ..."
	rm -f $PREFIX/$2/getnextline.h
else
	if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ];
	then
		echo "Install in prefix : $PREFIX"
		echo "Install librarys ..."
		mkdir -p $PREFIX/`dirname $1`
		cp $1 $PREFIX/`dirname $1`
		mkdir -p $PREFIX/$2
		echo "Install includes ..."
		cp $2/getnextline.h $PREFIX/$2
	fi
fi
