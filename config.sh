#!/bin/bash
echo -e "请输入数据库账号(输入后回车):"
read -r -p "" USERNAME

echo -e "请输入数据库密码(输入后回车):"
read -r -p "" PASSWORD
	
echo -e "请输入数据库地址(本地就填127.0.0.1:3306 云端或远程自行填写地址+端口号 输入后回车):"
read -r -p "" URL

cat << EOF > ${FDD_DIR}/config/application.yml
server:
  port: 8080
spring:
  mvc:
    static-path-pattern: /static/**
  freemarker:
    cache: false
    checkTemplateLocation: true
    contentType: text/html
    suffix: .html
    templateEncoding: UTF-8
    templateLoaderPath: classpath:templates
  datasource:
    password: ${PASSWORD}
    driverClassName: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://${URL}/emotion?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone
      = GMT
    username: ${USERNAME}
mybatis-plus:
  mapper-locations: classpath:mybatis/*.xml
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
EOF

echo "手动写入配置文件成功！如需修改，请前往fdd/config文件夹中编辑修改"