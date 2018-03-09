# easy-docker

## 一、目的
日常工作中，有时候需要运行安装Linux环境，平时多用VBox做环境模拟测试。随着Docker出现，可以替换掉VBox使用，利用Docker轻量级隔离的机制，为Linux下的软件，提供运行时的环境。如：hdfs，spark，hbase，hive，druid，zk，elk等，都可以依赖于Java底层镜像，用docker隔离出运行环境，而不用打包成镜像那样使用。只用docker隔离运行环境，启动很快，占用存储空间少。（软件安装包过大17G左右，只上传了主要封装脚本）

## 二、基本命令
### 启动停止app
```
service start|stop|restart|log app
```
### 进入容器
``` 
service ssh app
```
## 三、示例

### ZK
```
service start zk
```
### HDFS
```
service start hdfs
```
### HBase
```
service start hbase
```
### Spark
```
service start spark
```
### Drill
```
service start drill
```
### Druid
```
service start druid
```
### Zeppelin
```
service start zeppelin
```