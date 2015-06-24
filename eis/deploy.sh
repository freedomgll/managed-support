#!/bin/bash

function restoreOracle() {

	local DB_USER=LGU_DEV
	local DB_PWD=EXIGEN
	local DB_SID=orcl
	local DB_DUMP=EIS4DUMP_610.DMP
	local SOURCE_SCHEMA=eis4dump

	if [ $# -eq 5 ]; then
		DB_USER=$1
		DB_PWD=$2
		DB_SID=$3
		DB_DUMP=$4
		SOURCE_SCHEMA=$5
	fi
	
	sqlplus "/ as sysdba" <<EOF
	define DB_USER="$DB_USER";
	define DB_PWD="$DB_PWD";
	define DB_SID="$DB_SID";
	
	drop user &&DB_USER. cascade;
	create user &&DB_USER. identified by &&DB_PWD. account unlock;
	grant connect to &&DB_USER.;
	grant resource to &&DB_USER.;
	grant create view to &&DB_USER.;
	create or replace directory DATA_PUMP_DIR as '$DATA_PUMP_DIR';
	grant read,write ON DIRECTORY DATA_PUMP_DIR TO &&DB_USER.;
	grant exp_full_database to &&DB_USER.;
	grant all privileges to &&DB_USER.;
	exit;
EOF

    impdp $DB_USER/$DB_PWD REMAP_SCHEMA=$SOURCE_SCHEMA:$DB_USER directory=DATA_PUMP_DIR dumpfile=$DB_DUMP schemas=$SOURCE_SCHEMA LOGFILE=eis4dump.log
}

function restore610()
{
	restoreOracle "LGU_DEV" "EXIGEN" "orcl" "EIS4DUMP_610.DMP" "eis4dump"
}

function restore620()
{
	restoreOracle "LGU_DEV" "EXIGEN" "orcl" "EIS4DUMP_620.DMP" "eis4dump"
}

function restoreLGU_DEV()
{
	restoreOracle "LGU_DEV" "EXIGEN" "orcl" "LGU_DEV.DMP" "LGU_DEV"
}

function exportLGU_DEV()
{
	local db_name=LGU_DEV
	local db_password=EXIGEN
	local db_instance=orcl

	logtime=`date +%Y%m%d%H%M%S`

	expdp ${db_name}/${db_password}@${db_instance} dumpfile=${db_name}_${logtime}.DMP DIRECTORY=DATA_PUMP_DIR SCHEMAS=${db_name}  NOLOGFILE=Y
	cp -f ${DATA_PUMP_DIR}/${db_name}_${logtime}.DMP ${DATA_PUMP_DIR}/${db_name}.DMP
}

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
