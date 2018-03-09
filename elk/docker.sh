#!/bin/bash

# 安装
function install(){

	if [ ! -f "$APP_HOME/installed" ];then
		echo "install begin--------------------------------------"
		
		# ELASTICSEARCH
		app="elasticsearch"
		echo "install => $app"
		
		# KIBANA
		app="kibana"
		echo "install => $app"

		# LOGSTASH
		app="logstash"
		echo "install => $app"
	
		# FILEBEAT
		app="filebeat"
		echo "install => $app"
		#$APP_HOME/lib/$app/filebeat setup --dashboards
		#$APP_HOME/lib/$app/bin/logstash-plugin update logstash-input-beats
		#$APP_HOME/lib/$app/filebeat setup --template -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

		# CEREBRO
		app="cerebro"
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
	KIBANA_HOME=$APP_HOME/kibana
	CEREBRO_HOME=$APP_HOME/cerebro
	LOGSTASH_HOME=$APP_HOME/logstash
	FILEBEAT_HOME=$APP_HOME/filebeat
	ELASTICSEARCH_HOME=$APP_HOME/elasticsearch
	
	# PATH
	echo "PATH => $PATH"
	
	# ELASTICSEARCH
	echo "start => ELASTICSEARCH"
	useradd elk -g root
	gosu elk $ELASTICSEARCH_HOME/bin/elasticsearch &

	# CEREBRO
	echo "start => CEREBRO"
	$CEREBRO_HOME/bin/cerebro &

	# KIBANA
	echo "start => KIBANA"
	$KIBANA_HOME/bin/kibana &
	
	# LOGSTASH
	echo "start => LOGSTASH"
	#$LOGSTASH_HOME/bin/logstash -f $LOGSTASH_HOME/config/logstash.conf &
	
	# FILEBEAT
	echo "start => FILEBEAT"
	#$FILEBEAT_HOME/filebeat -e -c $FILEBEAT_HOME/filebeat.yml -d "publish" &

	echo "start end--------------------------------------"
}

# 日志
function log(){
	tail -f  $ELASTICSEARCH_HOME/logs/elasticsearch.log
	tail -f /dev/null
}

# 入口
function main(){
	install
	start
	log
}

main
