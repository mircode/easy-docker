
# 一、常用查询接口

## 1、按日期分片
```sql

use dfs.tmp;
alter session set `store.format`='parquet';

# 使用分区函数
create table dfs.tmp.analysis_day partition by(substr(pt_date,1,5),substr(pt_date,5,7),pt_date) as select * from mongo.perftrace.analysis_day;

# 手动分片 
create table dfs.tmp.`analysis_day/2016/01`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160101' and pt_date<'20160201';
create table dfs.tmp.`analysis_day/2016/02`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160201' and pt_date<'20160301';
create table dfs.tmp.`analysis_day/2016/03`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160301' and pt_date<'20160401';
create table dfs.tmp.`analysis_day/2016/04`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160401' and pt_date<'20160501';
create table dfs.tmp.`analysis_day/2016/05`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160520' and pt_date<'20160601';
create table dfs.tmp.`analysis_day/2016/06`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160601' and pt_date<'20160701';
create table dfs.tmp.`analysis_day/2016/07`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160701' and pt_date<'20160801';
create table dfs.tmp.`analysis_day/2016/08`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160801' and pt_date<'20160901';
create table dfs.tmp.`analysis_day/2016/09`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20160901' and pt_date<'20161001';
create table dfs.tmp.`analysis_day/2016/10`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20161001' and pt_date<'20161101';
create table dfs.tmp.`analysis_day/2016/11`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20161101' and pt_date<'20161201';
create table dfs.tmp.`analysis_day/2016/12`  as select * from mongo.perftrace.`analysis_day` where pt_date>='20161201' and pt_date<'20170101';

# 使用load.sh脚本
./load.sh date=20150501-20171124 saveby=month file=analysis_day

# 查看
show files;
show files in dfs.tmp.analysis_day;

```

## 2、分组查询
```sql

# 简单
select pt_user,pt_date,sum(pt_count) from analysis_day group by pt_date;

# 指定分区
select pt_user,pt_date,sum(pt_count) from analysis_day where dir0=2017 and dir1=11 group by pt_date;

# 复杂示例(接口错误率统计)
select * from (
	select a.pt_user,a.pt_service,a.pt_code,a.pt_count,b.pt_count as pt_all,(a.pt_count*100.0/b.pt_count) as pt_fail 
		from 
			(select  pt_user,pt_service,pt_code,sum(pt_count) as pt_count from dfs.perftrace.analysis_day 
				where pt_date>=20171122 and dir0>=201711  and pt_date<=20171129 and dir0<=201711  
				group by  pt_user,pt_service,pt_code) a 
		join 
			(select  pt_user,pt_service,sum(pt_count) as pt_count from dfs.perftrace.analysis_day 
				where pt_date>=20171122 and dir0>=201711  and pt_date<=20171129 and dir0<=201711  
				group by  pt_user,pt_service) b 
		on a.pt_user=b.pt_user and a.pt_service=b.pt_service
) where pt_code<>'1' order by pt_user,pt_service,pt_fail desc


```


# 二、附录

1.目录查询
https://drill.apache.org/docs/querying-directories/
https://drill.apache.org/docs/query-directory-functions/
2.创建分区表
https://drill.apache.org/docs/create-table-as-ctas/
https://drill.apache.org/docs/partition-by-clause/
3.空处理
https://drill.apache.org/docs/text-files-csv-tsv-psv/
4.学习博客
https://blog.gmem.cc/apache-drill-study-note
https://www.yuanmas.com/info/n4ObRv9MOw.html