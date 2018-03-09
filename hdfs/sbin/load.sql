create database if not exists perftrace;
use perftrace;
create external table if not exists mongo_analysis_day (pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int) stored by 'com.mongodb.hadoop.hive.MongoStorageHandler' tblproperties('mongo.uri'='mongodb://local:27017/perftrace.analysis_day');
create table if not exists analysis_day(pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int) partitioned by (dir0 string)  stored as parquet location '/perftrace/analysis_day';
set hive.execution.engine=tez;
set mapreduce.map.java.opts=-Xmx2048m -XX:-UseGCOverheadLimit;
set mapreduce.map.reduce.opts=-Xmx2048m -XX:-UseGCOverheadLimit;
set mapreduce.map.memory.mb=3072;
set mapreduce.reduce.memory.mb=3072;
add jar /opt/app/hdfs/lib/hive/lib/mongo-hadoop-core-2.0.2.jar;
add jar /opt/app/hdfs/lib/hive/lib/mongo-hadoop-hive-2.0.2.jar;
add jar /opt/app/hdfs/lib/hive/lib/mongo-java-driver-3.5.0.jar;
alter table analysis_day drop if exists partition (dir0='201505');
insert into table analysis_day partition (dir0='201505') select pt_user,pt_service,pt_code,pt_ip,pt_user_ip,pt_date,pt_count from mongo_analysis_day where pt_date>='20150501' and pt_date<'20150601';

