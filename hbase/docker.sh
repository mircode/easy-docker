#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
		
		# HBASE
		app="hbase"
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
	PHOENIX_HOME=$APP_HOME/phoenix
	HBASE_HOME=$APP_HOME/hbase

	# PATH
	echo "PATH => $PATH"
	
	# HBASE
	echo "start => HBASE"
	$HBASE_HOME/bin/start-hbase.sh

	# PHOENIX_HOME
	echo "start => PHOENIX_HOME"
	$PHOENIX_HOME/bin/queryserver.py start &

	echo "start end--------------------------------------"
}

# 日志
function log(){
	tail -f $HBASE_HOME/logs/hbase--master-hbase.log
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main
