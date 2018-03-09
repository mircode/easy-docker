#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
	
		# DRILL
		app="drill"
		echo "install => $app"

		# FLAG
		touch $APP_HOME/installed
		
		echo "install end--------------------------------------"
	fi
}

# 启动
function start(){
	echo "start begin--------------------------------------"
	
	# HOME
	DRILLBIT_HOME=$APP_HOME/drill

	# PATH
	echo "PATH => $PATH"

	# DRILL
	$DRILLBIT_HOME/bin/drillbit.sh start

	echo "start end--------------------------------------"
}

# 日志
function log(){
	tail -f $DRILLBIT_HOME/log/drillbit.out
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main