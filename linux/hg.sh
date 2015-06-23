#!/bin/bash

#hg pull from  repo of directories
function pull() {
	path=.
	echo $path
	if [ "$1" != "" ]; then
		path=$1
	fi
	
	for file in $path/*
	do 
		if [ -d "$file" ]
		then 
		  echo $file
		  hg --repository $file pull -u -r default --insecure --verbose
		fi
	done
}