#!/usr/bin/env python
#coding:utf-8

import datetime,time
import os,sys
import pymongo

from calendar import monthrange 
from elasticsearch import Elasticsearch  
from elasticsearch import helpers  


mongo_url='mongodb://localhost:27017';
elstc_url='http://localhost:9200';

# 日志
def log(log):
	print(log)

# 执行
def commnd(query):
	
	# MongoDB
	source=pymongo.MongoClient(mongo_url).perftrace.analysis_day;
	log('connect mongo'+'-['+mongo_url+'] success');
	
	# ES
	target=Elasticsearch(elstc_url);
	log('connect elk'+'-['+elstc_url+'] success');
	
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
def load(mongo,es,filter):
	sys.stdout.write("\n");
	start=filter['start'];
	end=filter['end'];
	info=filter['index'];
	query={'pt_date':{'$gte':start,'$lt':end}};
	data=mongo.find(query);
	
	total=data.count();
	index=0;
	segments=[];
	for doc in data:
		id=doc['_id'].__str__();
		del doc['_id'];
		if '_class' in doc:
			del doc['_class'];
		
		# 时间戳
		doc['@timestamp']=time.strftime("%Y-%m-%dT%H:%M:%S.000+0800",time.strptime(doc['pt_date'], '%Y%m%d'));
		segment={"_index":"perftrace","_type":"analysis_day","_id":id,"_source":doc}  
		segments.append(segment)  
		if(len(segments)==1000):  
			helpers.bulk(es,segments);
			del segments[0:len(segments)];
			index+=1000;
			process(info,index/total);
  
	if (len(segments)>0):  
		helpers.bulk(es,segments);
		index+=len(segments);
		process(info,index/total);
		
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