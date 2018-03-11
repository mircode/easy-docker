# easy-docker

## 一、目的
日常工作中，有时候需要运行安装Linux环境，平时多用VBox做环境模拟测试。随着Docker出现，可以替换掉VBox使用，利用Docker轻量级隔离的机制，为Linux下的软件，提供运行时的环境。如：hdfs，spark，hbase，hive，druid，zk，elk等，都可以依赖于Java底层镜像，用docker隔离出运行环境，而不用打包成镜像那样使用。只用docker隔离运行环境，启动很快，占用存储空间少。（软件安装包过大17G左右，只上传了主要封装脚本）

## 二、基本命令
![基本命令][1]
### 1、应用管理
提供安装卸载，启动停止重启，日志调试，进入容器，进入Docker命令
```
service install/uninstall/start/stop/restart/ssh/log/debug/docker name
```
细节参见ZK操作
### 2、应用监控
查询当前正在运行的app，并监控内存和CPU占用
``` 
service ps/ls/top
```
当前文件列表
![ls][2]
当前正在运行的容器
![ps][3]
容器资源占有率
![top][4]


## 四、使用
首先构建基础镜像，然后执行对应service install|start命令。
![构建基础镜像][5]

## 三、示例

### ZK
#### 1、安装
![安装][6]
#### 2、进入
![进入][7]
#### 3、重启
![重启][8]
#### 4、日志
![日志][9]

### HDFS
#### 1、安装
![安装][10]
#### 2、查看
![查看][11]
#### 3、运行
![运行][12]

### ELK
#### 1、安装
![安装][13]
#### 2、运行
![运行][14]

### Druid
#### 1、安装
![安装][15]

#### 2、运行
![运行][16]

### Drill
#### 1、安装
![安装][17]
#### 2、运行
![运行][18]

### Zeppelin
![测试][19]


  [1]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/help.jpg
  [2]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/ls.jpg
  [3]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/top.jpg
  [4]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/tp.jpg
  [5]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/jdk.jpg
  [6]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/zk.jpg
  [7]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/ssh.jpg
  [8]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/zk-restart.jpg
  [9]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/zk-log.jpg
  [10]: https://github.com/mircode/easy-docker/blob/master/images/hdfs-install.jpg
  [11]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/hdfs-ssh.jpg
  [12]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/hadoop.jpg
  [13]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/elk.jpg
  [14]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/elk-1.jpg
  [15]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/druid-install.jpg
  [16]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/druid-ui.jpg
  [17]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/drill-install.jpg
  [18]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/drill-select.jpg
  [19]: https://raw.githubusercontent.com/mircode/easy-docker/master/images/zeppelin.jpg