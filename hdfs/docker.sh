#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
		
		# HDFS
		app="hadoop"
		echo "install => $app"
		
		# HIVE
		app="hive"
		echo "install => $app"

		# MONGO
		cp  $APP_HOME/lib/mongo/*.jar $APP_HOME/hive/lib/

		#echo "init $app metadata"
		#$APP_HOME/lib/hive/bin/schematool -dbType mysql -initSchema
		
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
	HADOOP_HOME=$APP_HOME/hadoop
	HBASE_HOME=$APP_HOME/hbase
	HIVE_HOME=$APP_HOME/hive
	TEZ_HOME=$APP_HOME/lib/tez
	
	# PATH
	echo "PATH => $PATH"
	
	# SSH
	echo "start => SSH"
	/root/sshd.sh
	
	# HDFS
	echo "start => HDFS"
	$HADOOP_HOME/sbin/start-all.sh
	$HADOOP_HOME/sbin/hadoop-daemon.sh --script $HADOOP_HOME/bin/hdfs start portmap
	$HADOOP_HOME/sbin/hadoop-daemon.sh --script $HADOOP_HOME/bin/hdfs stop nfs3
	$HADOOP_HOME/sbin/hadoop-daemon.sh --script $HADOOP_HOME/bin/hdfs start nfs3
	
	# HIVE
	echo "start => HIVE"
	$HIVE_HOME/bin/hiveserver2 &
	
	# TEZ
	echo "start => TEZ"
	$HADOOP_HOME/bin/hadoop fs -mkdir -p /tez
	$HADOOP_HOME/bin/hadoop fs -put -f $TEZ_HOME/share/tez.tar.gz  /tez
	
	# NFS
	echo "start => NFS"
	mount -t nfs -o vers=3,proto=tcp,nolock,noacl localhost:/  $APP_HOME/nfs

	echo "start end--------------------------------------"
}

# 日志
function log(){
	tail -f  $HADOOP_HOME/logs/hadoop-root-namenode-hdfs.log
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main
