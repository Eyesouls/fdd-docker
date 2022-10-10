#!/bin/bash

# 安装node依赖
if [ ! -d ${FDD_DIR}/changePro/node_modules ]; then
   echo "开始安装依赖！"
   cd ${FDD_DIR}/changePro/
   yarn install --prod
   if [ "$?" != "0" ]; then
      echo -e "依赖安装出错，请检查容器网络是否通畅！资产查询启动出错！！
请手动执行资产配置启动文件changepro.sh或重启容器激活程序运行！！"
      rm -rf ${FDD_DIR}/changePro/node_modules ${FDD_DIR}/changePro/yarn-error.log
      exit 1
   else 
      echo "依赖安装完成！"
   fi
fi

#清除pm2日志文件
pm2 flush >/dev/null
#加入定时任务
#if [ ! "$(grep "pm2 flush" /var/spool/cron/crontabs/root)" ]; then
#   echo "写入清理pm2日志文件定时任务"
#   echo "0 0 */5 * * pm2 flush >/dev/null" > /var/spool/cron/crontabs/root
#fi
#pid=`ps -ef |grep "crond" | grep -v grep | awk '{print $1}'`
#if [ -n "$pid" ]; then
#   kill -9 $pid && crond >/dev/null 2>&1
#else
#   crond >/dev/null 2>&1
#fi

#配置pm2启动文件
pm2_config=${FDD_DIR}/changePro/ecosystem.config.js
if [ ! -s ${pm2_config} ]; then
cat << EOF > $pm2_config
module.exports = {
  apps : [{
    name: 'changePro',
    script: '$FDD_DIR/changePro/app.js',
    instances: 'max',
    cron_restart: '0 3 * * *',
    restart_delay: 3000,
    exec_mode: 'cluster_mode',
    max_memory_restart: '300M',
    stop_exit_codes: [0],
    error_file: '/dev/null',
    out_file: '/dev/null',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production'
    }
  }]
}
EOF
fi

#启动程序
pm2 start ${FDD_DIR}/changePro/ecosystem.config.js
#pm2 start ${FDD_DIR}/changePro/app.js -n fdd -i max --time --max-memory-restart 300M
sleep 3s
if [ "$(netstat -tunlp | grep 3100)" ]; then
   echo "资产查询功能启动成功！默认端口号：3100"
else
   echo "未检测到3100端口，资产查询功能启动出错！请尝试重启容器！"
   rm -rf ${FDD_DIR}/changePro/node_modules
fi
