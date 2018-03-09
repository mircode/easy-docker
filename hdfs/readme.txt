
add jar /opt/app/hdfs/lib/hive/lib/mongo-hadoop-core-2.0.2.jar;
add jar /opt/app/hdfs/lib/hive/lib/mongo-hadoop-hive-2.0.2.jar;
add jar /opt/app/hdfs/lib/hive/lib/mongo-java-driver-3.5.0.jar;
# test
create database if not exists perftrace location '/perftrace';
use perftrace;
create external table if not exists test(wgx string,name string) stored by 'com.mongodb.hadoop.hive.MongoStorageHandler' tblproperties('mongo.uri'='mongodb://local:27017/perftrace.hive'); 
create table test2(wgx string,name string) partitioned by (dir0 string) stored as parquet location '/perftrace/test2/'; 
insert into table test2 partition (dir0='201701') select * from test;
select * from test2;


add jar hdfs://localhost:9000/mongo-hadoop-core-2.0.2.jar;
add jar hdfs://localhost:9000/mongo-hadoop-hive-2.0.2.jar;
add jar hdfs://localhost:9000/mongo-java-driver-3.5.0.jar;


# source
create database if not exists perftrace location '/perftrace';
use perftrace;
create external table if not exists mongo_analysis_day (pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int) stored by 'com.mongodb.hadoop.hive.MongoStorageHandler' with serdeproperties('mongo.columns.mapping'='{"pt_user":"pt_user","pt_service":"pt_service","pt_code":"pt_code","pt_ip":"pt_ip","pt_user_ip":"pt_user_ip","pt_date":"pt_date","pt_count":"pt_count"}') tblproperties('mongo.uri'='mongodb://local:27017/perftrace.analysis_day');



create external table if not exists mongo_analysis_day (
	pt_user  	 string,
	pt_service	 string,
	pt_code      string,
	pt_ip        string,
	pt_user_ip   string,
	pt_date      string,
	pt_count     int
)
stored by 'com.mongodb.hadoop.hive.MongoStorageHandler'
with serdeproperties('mongo.columns.mapping'='{"pt_user":"pt_user","pt_service":"pt_service","pt_code":"pt_code","pt_ip":"pt_ip","pt_user_ip":"pt_user_ip","pt_date":"pt_date","pt_count":"pt_count"}')
tblproperties('mongo.uri'='mongodb://local:27017/perftrace.analysis_day');




# target
create table analysis_day(
    pt_user  	 string,
	pt_service	 string,
	pt_code      string,
	pt_ip        string,
	pt_user_ip   string,
	pt_date      string,
	pt_count     int
)
partitioned by (dir0 string)
stored as parquet
location '/perftrace/analysis_day/'; 


create table analysis_day(pt_user string,pt_service string,pt_code string,pt_ip string,pt_user_ip string,pt_date string,pt_count int) partitioned by (dir0 string) stored as parquet location '/perftrace/analysis_day/';


create table analysis_day like mongo_analysis_day partitioned by (dir0 string) stored as parquet location '/perftrace/analysis_day/'; 

# insert
insert into table analysis_day partition (dir0='201701') select * from mongo_analysis_day where pt_date>='20170101' and pt_date<'20170201';
insert into table analysis_day partition (dir0='201702') select * from mongo_analysis_day where pt_date>='20170201' and pt_date<'20170301';
insert into table analysis_day partition (dir0='201703') select * from mongo_analysis_day where pt_date>='20170301' and pt_date<'20170401';
insert into table analysis_day partition (dir0='201704') select * from mongo_analysis_day where pt_date>='20170401' and pt_date<'20170501';
insert into table analysis_day partition (dir0='201705') select * from mongo_analysis_day where pt_date>='20170501' and pt_date<'20170601';
insert into table analysis_day partition (dir0='201706') select * from mongo_analysis_day where pt_date>='20170601' and pt_date<'20170701';
insert into table analysis_day partition (dir0='201707') select * from mongo_analysis_day where pt_date>='20170701' and pt_date<'20170801';
insert into table analysis_day partition (dir0='201708') select * from mongo_analysis_day where pt_date>='20170801' and pt_date<'20170901';
insert into table analysis_day partition (dir0='201709') select * from mongo_analysis_day where pt_date>='20170901' and pt_date<'20171001';
insert into table analysis_day partition (dir0='201710') select * from mongo_analysis_day where pt_date>='20171001' and pt_date<'20171101';
insert into table analysis_day partition (dir0='201711') select * from mongo_analysis_day where pt_date>='20171101' and pt_date<'20171201';

# load
load data local inpath '/perftrace/analysis_day/201701' partition overwrite into table analysis_day;
load data inpath '/perftrace/analysis_day/201701' partition overwrite into table analysis_day;


# select
select * from analysis_day where dir0='201701'; 

# update partition
alter table analysis_day add  partition (dir0='201701') location '/perftrace/analysis_day/201701';  
alter table analysis_day drop partition (dir0='201701') 