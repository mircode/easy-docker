#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
	
		# ZEPPELIN
		app="zeppelin"
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
	ZEPPELIN_HOME=/opt/app/zeppelin/zeppelin
	
	# PATH
	echo "PATH => $PATH"
	
	# ZEPPELIN
	$ZEPPELIN_HOME/bin/zeppelin-daemon.sh start
	
	echo "start end--------------------------------------"
}

# 日志
function log(){
    tail -f $ZEPPELIN_HOME/log/zeppelin--zeppelin.log
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main