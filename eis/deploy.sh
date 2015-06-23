#!/bin/bash

#get repository jars from http://suzeisci02.exigengroup.com/jenkins/view/EIS-Central
function getrepozip()
{
	cd $PATH_REPOSITORY 
	rm -rf * 
	wget http://suzeisci02.exigengroup.com/jenkins/view/EIS-Central/job/EIS-Central-Nightly-Build/lastSuccessfulBuild/artifact/repository.zip
	unzip -q repository.zip
	mv .repository/* ./ 
}

function deployprocess()
{
	local file=$ANT_FILE
	local tomcatRoot=$TOMCAT_ROOT
	local environment=$ENVIRONMENT
	local artifactPath=$PATH_ARTIFACT
	
	if [ $# -eq 5 ]; then
		file=$2
		tomcatRoot=$3
		environment=$4
		artifactPath=$5
	fi
    
	ant -file $file                                                                                                           \
		-DtomcatRoot=$tomcatRoot                                                                                              \
		-Denvironment=$environment                                                                                            \
		-DartifactPath=$artifactPath                                                                                          \
		-Duser.country=US                                                                                                     \
		-Duser.language=en                                                                                                    \
		-Dmaxwait=20                                                                                                          \
		-DdeployRemoteInvocationTimeout=600000                                                                                \
		\"-DJAVA_OPTS=-Xms512M -Xmx5072M -XX:MaxPermSize=2560M -Djava.util.Arrays.useLegacyMergeSort=true -Duser.language=en -Duser.country=US -Djava.awt.headless=true -server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 \" \
		$1
}

function preparework()
{
	rm -rf $PATH_ARTIFACT/*
	cp $PATH_PRECONFIG_CENTRAL/applications/preconfig-central-deploy/target/webdeploy-build.xml /reworks/eis_deploy_ws/
	cp $PATH_PRECONFIG_CENTRAL/applications/preconfig-central-deploy/target/ipb-deploy-dist.zip /reworks/eis_deploy_ws/
	cp -r $PATH_PRECONFIG_CENTRAL/applications/*/target/*.war /reworks/eis_deploy_ws/
}

function deployapp()
{
	deployprocess "db.prepare webdeploy.node8 app.prepare processes products docgen"	 
}

function startapp()
{
	deployprocess "webdeploy.node8"
}
