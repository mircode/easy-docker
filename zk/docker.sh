#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
		
		# ZOOKEEPER
		app="zookeeper"
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
	ZOOKEEPER_HOME=$APP_HOME/zookeeper

	# PATH
	echo "PATH => $PATH"
	
	# ZK
	$ZOOKEEPER_HOME/bin/zkServer.sh start

	echo "start end--------------------------------------"
}

# 日志
function log(){
    tail -f $ZOOKEEPER_HOME/log/zookeeper.out
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main