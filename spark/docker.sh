#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
				
		# SPARK
		app="spark"
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
	SPARK_HOME=$APP_HOME/spark
	
	# PATH
	echo "PATH => $PATH"
	
	# SSH
	echo "start => SSH"
	/root/sshd.sh

	# SPARK
	echo "start => spark"
	$SPARK_HOME/sbin/start-all.sh &
	$SPARK_HOME/sbin/start-thriftserver.sh &

	echo "start end--------------------------------------"
}

# 日志
function log(){
	tail -f  $SPARK_HOME/log/spark--org.apache.spark.deploy.master.Master-1-spark.out
	tail -f  /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main
