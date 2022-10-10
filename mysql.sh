#!/bin/bash
set -e

app_name="mysqld"
pid=`ps -ef |grep "${app_name}" | grep -v grep | awk '{print $1}'`
if [ -n "$pid" ]; then
      echo "[!] MySQL has been started，Ready to kill!"
      kill -9 $pid
fi

if [ -d /etc/my.cnf.d ]; then
  sed -i "s|.*skip-networking.*|#skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
fi

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
fi

if [ -d ${FDD_DIR}/mysql/mysql ]; then
  echo "[i] MySQL directory already present, skipping creation"
else
  echo "[!] MySQL data directory not found, creating initial DBs"

  mysql_install_db --user=root > /dev/null
  
  if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    MYSQL_ROOT_PASSWORD=123456
  fi
  echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"

  MYSQL_DATABASE=${MYSQL_DATABASE:-""}
  MYSQL_USER=${MYSQL_USER:-""}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}
  SERCET_KEY=${SERCET_KEY:-""}

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi

  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
EOF

  if [ "$MYSQL_DATABASE" != "" ]; then
    echo "[i] Creating database: $MYSQL_DATABASE"
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

    if [ "$MYSQL_USER" != "" ]; then
      echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
      echo -e "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
      GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
    fi
  fi

  if [ "$SERCET_KEY" != "" ]; then
      echo "[i] Creating table: sercetkey"
      echo -e "USE $MYSQL_DATABASE;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS \`sercetkey\`;
CREATE TABLE \`sercetkey\` (
  \`sercetkey\` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = DYNAMIC;
INSERT INTO \`sercetkey\` VALUES ('$SERCET_KEY');
SET FOREIGN_KEY_CHECKS = 1;" >> $tfile
  fi

  /usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile > /dev/null 2>&1
  sleep 3s
  rm -f $tfile
fi

exec /usr/bin/mysqld --user=root --console > /dev/null 2>&1 &