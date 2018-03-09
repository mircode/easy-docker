@echo off

:: 工作目录
set base=E:\opt\app

:: 参数
set act=%1
set app=%2

:: 信息
echo.
echo %act% %app% ......
	
:: 控制器
if ""%act%"" == ""ls"" 	      goto ls
if ""%act%"" == ""ps"" 	      goto ps
if ""%act%"" == ""ssh"" 	  goto ssh
if ""%act%"" == ""log""       goto log
if ""%act%"" == ""top""       goto top
if ""%act%"" == ""help""      goto help
if ""%act%"" == ""stop""      goto stop
if ""%act%"" == ""start""     goto start
if ""%act%"" == ""build""     goto build
if ""%act%"" == ""debug""     goto debug
if ""%act%"" == ""docker""    goto docker
if ""%act%"" == ""status"" 	  goto status
if ""%act%"" == ""restart""   goto restart
if ""%act%"" == ""install""   goto install
if ""%act%"" == ""uninstall"" goto uninstall
goto default


:: 列表
:ls
	dir %base% /B /AD
	goto end

:: 容器
:ps
	if ""%2"" == ""-a"" 	      goto psall
	docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
	goto end
	:: 详情
	:psall
		docker container ls -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
		goto end
:: 资源
:top
	if ""%2"" == ""-a"" 	      goto topall
	:: 概况
	docker container stats --format "table {{.PIDs}}\t{{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}"
	goto end
	:: 详情
	:topall
		docker container stats --format "table {{.PIDs}}\t{{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
		goto end
		
:: 日志
:log
	docker-compose -f %base%\service.yml logs -f --tail="50" %app%
	goto end
	
:: 启动
:start
	docker-compose -f %base%\service.yml start %app%
	goto log
	
:: 停止
:stop
	docker-compose -f %base%\service.yml stop %app%
	goto log
	
:: 重启
:restart
	docker-compose -f %base%\service.yml restart %app%
	goto log

:: 安装
:install
	docker container rm -f %app%
	docker-compose -f %base%\service.yml up -d %app% 
	goto log
	
:: 卸载
:uninstall
	del %base%\%app%\installed
	docker container rm -f %app%
	goto log
	
:: 登录
:ssh
	docker-compose -f %base%\service.yml exec %app% bash
	goto end

:: 调试
:debug
	docker container rm -f %app%_debug
	docker-compose -f %base%\service.yml run --name %app%_debug %3 %4 %5 %6 %7 %8 --rm %app% bash
	goto end

:: 构建
:build
	docker image rm -f %app%
	docker-compose -f %base%\service.yml build %app%
	goto end

:: 状态
:status
	docker-compose -f %base%\service.yml ps %app%
	goto end

:: 默认
:default
	docker-compose -f %base%\service.yml %act% %app%
	goto end
	
:: 虚机
:docker
	docker run -it --rm --privileged --pid=host --name vm debian nsenter -t 1 -m -u -i -n sh
	goto end

:: 帮助
:help
	echo usage:
	echo      service ps/ls/top
	echo      service install/uninstall/start/stop/restart/ssh/log/debug/docker name
	goto end

:end