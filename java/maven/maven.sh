#!/bin/bash

#mvn -f $path/pom.xml clean install -Dapps=main -Ddeploy-db -Dmaven.test.skip=true
function build() {
	path=.
	echo $path
	if [ "$1" != "" ]; then
		path=$1
	fi

	echo mvn -f $path/pom.xml clean install -Dapps=main -Ddeploy-db -Dmaven.test.skip=true 
	mvn -f $path/pom.xml clean install -Dapps=main -Ddeploy-db -Dmaven.test.skip=true 
}

#mvn -f $path/pom.xml clean test -Dmaven.test.failure.ignore=true -Dsonar=ut
function test() {
	path=.
	echo $path
	if [ "$1" != "" ]; then
		path=$1
	fi

	echo mvn -f $path/pom.xml clean test -Dmaven.test.failure.ignore=true -Dsonar=ut
	mvn -f $path/pom.xml clean test -Dmaven.test.failure.ignore=true -Dsonar=ut
}