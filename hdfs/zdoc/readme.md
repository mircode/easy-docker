# 安装手册
https://gist.github.com/ericzhong

# HBase
http://blog.csdn.net/yuan_xw/article/details/51560085
create 'test', 'cf'
list 'test'
put 'test', 'row1', 'cf:a', 'value1'
put 'test', 'row2', 'cf:b', 'value2'
put 'test', 'row3', 'cf:c', 'value3'

scan 'test'
get 'test', 'row1'
drop 'test'

# Phoenix
create table if not exists person (id integer not null primary key, name varchar(20),age integer);
upsert into person (id,name,age) values (100,'小明',12);
upsert into person (id,name,age) values (101,'小红',15);
upsert into person (id,name,age) values (103,'小王',22);
select * from person;
select name,count(name) as num from person where age>20 group by name;


create table if not exists analysis_day(id varchar primary key, pt_user varchar,pt_service varchar,pt_code varchar,pt_ip varchar,pt_user_ip varchar,pt_count integer,pt_date varchar)


#JDBC
http://www.linuxidc.com/Linux/2015-03/115273.htm
http://blog.csdn.net/maomaosi2009/article/details/45582321
https://segmentfault.com/a/1190000002936080