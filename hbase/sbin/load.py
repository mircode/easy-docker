#!/usr/bin/env python
#coding:utf-8

import datetime,time
import os,sys
import pymongo
import phoenixdb
from calendar import monthrange 


mongo_url='mongodb://localhost:27017';
phoenix_url='http://localhost:8765';

# 日志
def log(log):
	print(log)

# 执行
def commnd(query):
	
	# MongoDB
	source=pymongo.MongoClient(mongo_url).perftrace.analysis_day;
	log('connect mongo'+'-['+mongo_url+'] success');
	
	# HBase
	target=phoenixdb.connect(phoenix_url,autocommit=True)
	target=target.cursor();
	log('connect hbase'+'-['+phoenix_url+'] success');	
	target.execute("create table if not exists analysis_day(id varchar primary key, pt_user varchar,pt_service varchar,pt_code varchar,pt_ip varchar,pt_user_ip varchar,pt_count integer,pt_date varchar)");
	
	# 参数
	start=query['start'];
	end=query['end'];
	saveby='day' if len(start)==8 else 'month';
	
	if saveby=='day':
		start=datetime.datetime.strptime(start,'%Y%m%d');
		end=datetime.datetime.strptime(end,'%Y%m%d');
	else:
		start=datetime.datetime.strptime(start,'%Y%m');
		end=datetime.datetime.strptime(end,'%Y%m');
	
	# 导入
	while start<=end :
		
		index=start.strftime('%Y%m%d');
		offset=datetime.timedelta(days=1);
		s=start.strftime('%Y%m%d');
		e=(start+offset).strftime('%Y%m%d');
		if saveby=='month':
			index=start.strftime('%Y%m');
			offset=datetime.timedelta(days=monthrange(start.year,start.month)[1]);
			s=start.strftime('%Y%m01');
			e=(start+offset).strftime('%Y%m01');
			
		filter={'start':s,'end':e,'index':index};
		load(source,target,filter);
		start+=offset;
	
# 导入
def load(mongo,hbase,filter):
	sys.stdout.write("\n");
	start=filter['start'];
	end=filter['end'];
	info=filter['index'];
	query={'pt_date':{'$gte':start,'$lt':end}};
	data=mongo.find(query,no_cursor_timeout=True);
	
	total=data.count();
	index=0;
	segments=[];
	for doc in data:
		id=doc['_id'].__str__();
		segment=(id,doc.get('pt_user',None),doc.get('pt_service',None),doc.get('pt_code',None),doc.get('pt_ip',None),doc.get('pt_user_ip',None),doc.get('pt_count',None),doc.get('pt_date',None));
		segments.append(segment)  
		if(len(segments)==1000):  
			bulk(hbase,segments);
			del segments[0:len(segments)];
			index+=1000;
			process(info,index/total);
  
	if (len(segments)>0):  
		bulk(hbase,segments);
		index+=len(segments);
		process(info,index/total);

# 导入
def bulk(hbase,segments):
	sql="upsert into analysis_day(id,pt_user,pt_service,pt_code,pt_ip,pt_user_ip,pt_count,pt_date) values(?,?,?,?,?,?,?,?)";
	hbase.executemany(sql,segments)
		
# 进度
def process(info,x):
	width=int(50*x);
	procss='index => '+info+'|'+'#'*width+'-'*(50-width)+'|'+format(x,'.0%')+' done';
	if x<100:
		sys.stdout.write(procss+"\r");   
	else:
		sys.stdout.write(procss+"\n");   
	
# 参数
def param(args):
	query={}
	range=(datetime.datetime.now()+datetime.timedelta(days=-2)).strftime('%Y%m%d');
	if len(args) == 2 :
		range=args[1];
	date=range.split('-');
	start=date[0];
	end=(start if len(date)==1 else date[1]);
	query['start']=start;
	query['end']=end;
	return query;
	
# 入口
def main(args): 
	start=time.clock()
	
	query=param(args);
	log('query => '+str(query));
	commnd(query);
	
	end=time.clock();
	sys.stdout.write("\n");
	log('load complete => ['+str(round(end-start,2))+'s]');

main(sys.argv)