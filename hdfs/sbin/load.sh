#!/bin/bash

# 未采用create table xxx partition by,而是分批次导入,支持增量。建议采用一级目录结构,查询性能会有提升。

# 配置
APP_HOME=/opt/app/hdfs/
URL="jdbc:hive2://localhost:10000";
USER="root";
FROM="select pt_user,pt_service,pt_code,pt_ip,pt_user_ip,pt_date,pt_count from mongo_analysis_day";
TO="analysis_day"

# 变量
SQL_FILE="$APP_HOME/sbin/load.sql"

# 清理文件
function clean(){
	rm -rf $SQL_FILE
}

# 切割
function splits(){
	str=$1;token=$2;
	arr=(${str//$token/ })
	echo "${arr[*]}";
}

# 日期
function getDate(){
	offset=$1;date=$2;type=$3;
	date=${date:-`date +%Y%m%d`};
	type=${type:-day};
	date=`date -d "$offset $type $date" +%Y%m%d`;
	echo $date;
}

# 生成SQL
function genSql(){
	file=$1;date=$2;saveby=$3;partby=$4;
	partition='';
	where='';
	if [[ $saveby == "year"  ]]
	then
		year=`date -d "$date" +%Y`;
		partition="partition (dir0='$year')";
		start=`getDate 0 $date year`;
		  end=`getDate 1 $start year`;
		where="where pt_date>='$start' and pt_date<'$end'";
	elif [[ $saveby == "month"  ]] 
	then 
		month=`date -d "$date" +%Y%m`;
		partition="partition (dir0='$month')";
		start=`getDate 0 $date month`;
		  end=`getDate 1 $start month`;
		where="where pt_date>='$start' and pt_date<'$end'";
	else
		year=`date -d "$date" +%Y`;
		monthday=`date -d "$date" +%m%d`;
		partition="partition (dir0='$year',dir1='$monthday')";
		start=`getDate 0 $date day`;
		  end=`getDate 1 $start day`;
		where="where pt_date='$date'";
	fi

	insert="insert into table $TO  $partition $FROM $where;";
	drop="alter table $TO drop if exists  $partition;";
	echo $drop   >> $SQL_FILE
	echo $insert >> $SQL_FILE
	
}

# 表结构
function initSql(){
	file=$1;date=$2;saveby=$3;partby=$4;
	partition='';
	clustered='';

	# 数据库
	DB="perftrace";
	echo "create database if not exists $DB;" >> $SQL_FILE
	echo "use perftrace;" >> $SQL_FILE

	field="pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int";
	url="mongodb://local:27017/perftrace.analysis_day";
	# Mongo表
	echo "create external table if not exists mongo_analysis_day ($field) stored by 'com.mongodb.hadoop.hive.MongoStorageHandler' tblproperties('mongo.uri'='$url');"   >> $SQL_FILE

	# 分区 分桶
	table='';
	if [[ $saveby == "year"  ]]
	then
		partition="partitioned by (dir0 string)";	
	elif [[ $saveby == "month"  ]] 
	then
		partition="partitioned by (dir0 string)";
	else
		partition="partitioned by (dir0 string,dir1 string)";
	fi
	if [[ $partby != "none"  ]]
	then
		clustered="clustered by ($partby) into 1000 buckets";
	fi
	
	# Hive表
	echo "create table if not exists $TO($field) $partition $clustered stored as parquet location '/$DB/$TO';" >> $SQL_FILE
	echo "set hive.execution.engine=tez;" >> $SQL_FILE
	
	# 启动任务内存限制
	echo "set mapreduce.map.java.opts=-Xmx2048m -XX:-UseGCOverheadLimit;"  >> $SQL_FILE
	echo "set mapreduce.map.reduce.opts=-Xmx2048m -XX:-UseGCOverheadLimit;"  >> $SQL_FILE
	# 最大内存
	echo "set mapreduce.map.memory.mb=3072;"      >> $SQL_FILE
	echo "set mapreduce.reduce.memory.mb=3072;"   >> $SQL_FILE

	echo "add jar /opt/app/hdfs/hive/lib/mongo-hadoop-core-2.0.2.jar;" >> $SQL_FILE
	echo "add jar /opt/app/hdfs/hive/lib/mongo-hadoop-hive-2.0.2.jar;" >> $SQL_FILE
	echo "add jar /opt/app/hdfs/hive/lib/mongo-java-driver-3.5.0.jar;" >> $SQL_FILE
}

# 参数
function getParam(){
	args=$1;target=$2;default=$3;
	res=$default;
	for i in ${args[*]}; do
		tokens=`splits $i =`;tokens=(${tokens[*]});
		key=${tokens[0]};
		val=${tokens[1]};
		if [[ $key == $target ]]
		then
			res=$val;break;
		fi
	done
	echo $res;
}

# 执行SQL
function command(){
	$APP_HOME/lib/hive/bin/beeline  -u $URL -n $USER -f $SQL_FILE
}

# 主函数
function main(){
	
	# 参数
	args=$@;
	
	# 初始化
	if [[  $# == 0 ]]
	then
		args=('date=20150501-20171201' 'saveby=month' 'file=analysis_day')
	fi
	
	# 解析
	   day=`getDate "-2"`;
	  file=`getParam "${args[*]}" file res`;
	  date=`getParam "${args[*]}" date $day`;
	saveby=`getParam "${args[*]}" saveby day`;
	partby=`getParam "${args[*]}" partby none`;
	
	# 日期	
	tokens=`splits $date -`;tokens=(${tokens[*]});
	begin=${tokens[0]};
	stop=${tokens[1]:-`getDate 1 $begin`};
	
	# 打印
	echo "date=$begin-$stop saveby=$saveby file=$file partby=$partby";
	
	# SQL
	clean;

	# 目标
	TO=$file;
	
	# DML
	initSql $file $begin $saveby $partby;
	
	# DDL
	while [[ $begin < $stop  ]]
	do   
		genSql $file $begin $saveby $partby;
		begin=`getDate "+1" $begin $saveby`;
	done
	
	# 执行
	command;
}


# 接口
# ./load.sh date=20160101-20170101 file=log_day   saveby=day   partby=pt_date
# ./load.sh date=20160101-20170101 file=log_year  saveby=year  partby=pt_date
# ./load.sh date=20160101-20170101 file=log_month saveby=month partby=pt_date

main $@
