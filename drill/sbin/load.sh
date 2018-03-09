#!/bin/bash

# 未采用create table xxx partition by,而是分批次导入,支持增量。建议采用一级目录结构,查询性能会有提升。

# 配置
APP_HOME=/opt/app/drill
URL="jdbc:drill:drillbit=localhost";
FROM="select pt_user,pt_service,pt_code,pt_ip,pt_user_ip,pt_date,pt_count from mongo.perftrace.analysis_day";
TO="dfs.perftrace"

# 变量
SQL_FILE="load.sql"

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
	table='';
	where='';
	if [[ $saveby == "year"  ]]
	then
		table=`date -d "$date" +$file/%Y`;
		start=`getDate 0 $date year`;
		  end=`getDate 1 $start year`;
		where="where pt_date>='$start' and pt_date<'$end'";
	elif [[ $saveby == "month"  ]] 
	then 
		table=`date -d "$date" +$file/%Y%m`;
		start=`getDate 0 $date month`;
		  end=`getDate 1 $start month`;
		where="where pt_date>='$start' and pt_date<'$end'";
	else
		table=`date -d "$date" +$file/%Y/%m%d`;
		start=`getDate 0 $date day`;
		  end=`getDate 1 $start day`;
		where="where pt_date='$date'";
	fi
	
	if [[ $partby != "none"  ]]
	then
		partition="partition by($partby)";
	fi
	
	create="create table $TO.\`$table\` $partition as $FROM $where;";
	drop="drop table if exists $TO.\`$table\`;";
	echo $drop   >> $SQL_FILE
	echo $create >> $SQL_FILE
	
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
	$APP_HOME/drill/bin/sqlline -u $URL -f $SQL_FILE
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
