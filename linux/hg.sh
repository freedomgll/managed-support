#!/bin/bash

#hg pull from  repo of directories
function pull() {
	if [ "$1" != "" ]; then
		path=$1
		for file in $path/*
		do 
			if [ -d "$file" ]
			then 
			  echo hg --repository $file pull -u -r default --insecure --verbose
			  hg --repository $file pull -u -r default --insecure --verbose
			fi
		done
	else
	    echo hg pull -u -r default --insecure --verbose
		hg pull -u -r default --insecure --verbose
	fi	
}