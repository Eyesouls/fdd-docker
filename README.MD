<p align="center">
    <a href="https://github.com/grbnb/fdd-docker"><img src="https://img.shields.io/pypi/l/daily?style=plastic" alt="license"></a>
    <a href="https://github.com/grbnb/fdd-docker"><img src="https://img.shields.io/github/stars/grbnb/fdd-docker.svg?logo=github&style=plastic" alt="GitHub stars"></a>
    <a href="https://github.com/grbnb/fdd-docker"><img src="https://img.shields.io/github/forks/grbnb/fdd-docker.svg?logo=github&style=plastic" alt="GitHub forks"></a>
    <a href="https://hub.docker.com/r/grbhq/fdd"><img src="https://img.shields.io/docker/pulls/grbhq/fdd?logo=docker&style=plastic" alt="Docker Pulls"></a>
    <a href="https://hub.docker.com/r/grbhq/fdd/"><img src="https://img.shields.io/docker/image-size/grbhq/fdd?logo=docker&style=plastic" alt="Docker Size"></a>
    <a href="https://hub.docker.com/r/grbhq/fdd/"><img src="https://img.shields.io/docker/stars/grbhq/fdd?logo=docker&style=plastic" alt="Docker Stars"></a>
</p>

### 说明：

> docker版fdd，原仓库地址：[QL-Emotion-jar](https://github.com/fengxiaoruia/QL-Emotion-jar.git) 另外在此特别鸣谢[grbnb](https://github.com/grbnb)提供方法

> docker基础镜像使用的是alpine3.15+nginx_1.18+openjdk8环境：

> 前端文件存储路径为`/usr/share/nginx/html/`

> 当前分支[三合一版]已增加内置资产查询功能！

> 资产查询功能内部默认端口8089，如有需求请自行添加外部端口映射！


## 食用方法：

### 1、运行fdd容器

#### ①启用内置MySQL数据库和资产查询(无需手动配置安装MySQL，正常启动后可直接访问前端)

```
docker run -dit \
  -v $PWD/fdd/config:/fdd/config \
  -v $PWD/fdd/mysql:/fdd/mysql \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=emotion \
  -e ENABLE_CHANGE=true \
  -e SERCET_KEY=abcd \
  -p 8088:80 \
  -p 3301:3306 \
  -p 8089:3100 \
--name fdd \
--restart always \
eyesouls/fdd:latest
```
> ARM机型将latest修改为arm64即可。

> 参数说明：

| 变量                  | 说明                                     |
|:-------------------:|:--------------------------------------:|
| MYSQL_ROOT_PASSWORD | MySQL的root密码，默认123456（可自定义）            |
| MYSQL_DATABASE      | MySQL启动时创建的数据库名，必须为emotion （不可修改）      |
| ENABLE_MYSQL        | 是否启用内置MySQL，只有为false时不启用               |
| ENABLE_CHANGE       | 是否启用内置资产查询功能，只有为true时启用                |
| SERCET_KEY          | 系统密钥(自定义禁止特殊符号)，长度必须≥4位，默认值为abcd（可自定义） |
| 8088                | fdd前端网页端口（可自定义）                        |
| 8089                | 内置资产查询外部连接端口（可自定义）                 |
| 3301                | 内置MySQL数据库外部连接端口（可自定义）                 |

#### ②不启用内置MySQL数据库但启用资产查询(需自备MySQL或使用云端MySQL)

```
docker run -dit \
 -v $PWD/fdd/config:/fdd/config \
 -e ENABLE_CHANGE=true \
 -e ENABLE_MYSQL=false \
 -p 8088:80 \
 -p 8089:3100 \
--name fdd \
--restart always \
eyesouls/fdd:latest
```

> 以上参数和端口请按需修改！！！

### 2、查看容器运行日志

- 查看容器运行日志

`docker logs -f fdd`

(1)判断MySQL是否正常启动
![MySQL启动正常](https://s2.loli.net/2022/10/04/LfvmgoIa6XEihM5.png)

(2)判断fdd后端服务是否启动正常
![fdd后台正常](https://s2.loli.net/2022/10/04/CNyTwWXkgsGZbK1.png)

- 只有以上日志正常后，fdd才算成功运行，此时前端才能正常使用

### 3、浏览器访问前端

> 浏览器访问`设备ip:8088`即可进入！【端口号按需修改】

- 点击管理员登陆，用户名和密码均为`root`

## 如果你需要配置机器人，请确保在容器交互模式下输入参数才有效；如不需要机器人，到这一步就OK啦，网页端基本功能都有！

### 4、进入容器交互模式，输入需要的参数（不启用内置MySQL的必需要用到）

进入容器交互模式命令
`docker attach fdd`

- 进入后若出现无任何提示，说明容器已处于等待输入指令状态，请直接输入即可。可通过查看logs最后打印的日志获取输入提醒！（即输入机器人账号）
- 按提示输入必要的参数即可！使用此命令后每次按``CTRL+C``退出时，容器会自动重启！！！
- 请使用`CTRL+P+Q`结束交互模式，容器才不会重启！！！

## 遇到如下问题

- 1、出现如下报错时，说明MySQL数据库启动过程中出现错误，请执行以下命令
  ![fdd启动失败](https://s1.328888.xyz/2022/10/03/PCnOF.png)

①停止容器再删除fdd文件夹并重启容器

(1)停止容器

`docker stop fdd`

(2)删除数据库文件

`rm -rf $PWD/fdd/mysql`

(3)重新启动容器

`docker restart fdd`

- 2、前端出现如下问题，请根据以下情况排查！
  ![fdd前端报错](https://s1.328888.xyz/2022/10/03/PCKHP.png)

（1）查看fdd后台服务是否正常
  根据报错的日志排除问题即可

（2）设置的系统密钥长度是否≥4位
系统密钥可通过使用MySQL管理工具连接数据库找到名为`sercetkey`的表头进行手动修改。

修改完成后请使用`docker restart fdd`重启容器！

【内置MySQL数据库默认外部端口为3301，用户名：root    密码：123456】

- 3、一键删除容器内的`device.json`文件和`cache`文件夹，解决机器人登陆可能出现的报错问题。

`docker exec -it fdd bash -c "rm -rf /fdd/cache /fdd/device.json"`
