#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
	
		# DRUID
		app="druid"
		echo "install => $app"
		mkdir -p ~/druid/sv
		mkdir -p $APP_HOME/lib/$app/var/
		rm -rf   $APP_HOME/lib/$app/var/sv
		ln -sf   ~/druid/sv $APP_HOME/lib/$app/var/sv

		# FLAG
		touch $APP_HOME/installed
		
		echo "install end--------------------------------------"
	fi
}

# 启动
function start(){
	echo "start begin--------------------------------------"
	
	# HOME
	DRUID_HOME=$APP_HOME/druid

	# PATH
	echo "PATH => $PATH"
	
	# DRUID
	$DRUID_HOME/bin/supervise -c $DRUID_HOME/conf/supervise/quickstart.conf

	echo "start end--------------------------------------"
}

# 日志
function log(){
    tail -f $DRUID_HOME/log/broker.log
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main