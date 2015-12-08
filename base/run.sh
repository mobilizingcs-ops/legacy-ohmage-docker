#!/usr/bin/env bash

set -e

# if a container is linked as 'mysql', this should exist
if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
  DB_PORT=$MYSQL_PORT_3306_TCP_PORT
else
  #assume no linked container.
  echo "RUNNING CONTAINER WITH EMBEDDED MYSQL. DESTROYING THE CONTAINER WILL ALSO DESTROY THE DATABASE" 
  DB_HOST=localhost
  DB_PORT=3306
fi
# use passed env variable or defaults
DB_NAME=${DB_NAME:-ohmage}
DB_USER=${DB_USER:-ohmage}
DB_PASS=${DB_PASS:-ohmage}
FQDN=${FQDN:-$HOSTNAME}
LOG_LEVEL=${LOG_LEVEL:-WARN}
 
# update ohmage conf to point to correct db
sed -i "s/^db.jdbcurl.*/db.jdbcurl=jdbc:mysql:\/\/$DB_HOST:$DB_PORT\/$DB_NAME?characterEncoding=utf8/" /etc/ohmage.conf
sed -i "s/^db.username.*/db.username=$DB_USER/" /etc/ohmage.conf
sed -i "s/^db.password.*/db.password=$DB_PASS/" /etc/ohmage.conf

# update ohmage conf to set logging level
sed -i "s/^log4j.rootLogger.*/log4j.rootLogger=$LOG_LEVEL, root, stdout/" /etc/ohmage.conf
sed -i "s/^log4j.appender.stdout.Threshold.*/log4j.appender.stdout.Threshold = $LOG_LEVEL/" /etc/ohmage.conf
sed -i "s/^log4j.logger.org.ohmage.*/log4j.logger.org.ohmage=$LOG_LEVEL/" /etc/ohmage.conf
sed -i "s/^log4j.logger.org.springframework.*/log4j.logger.org.springframework=$LOG_LEVEL/" /etc/ohmage.conf
sed -i "s/^log4j.logger.org.ohmage.util.JsonUtils.*/log4j.logger.org.ohmage.util.JsonUtils=$LOG_LEVEL/" /etc/ohmage.conf
sed -i "s/^log4j.logger.org.ohmage.cache.UserBin.*/log4j.logger.org.ohmage.cache.UserBin=$LOG_LEVEL/" /etc/ohmage.conf
 
# update flyway conf
# note that the placeholders wont be updated at each boot.
echo "flyway.url=jdbc:mysql://$DB_HOST:$DB_PORT/$DB_NAME
flyway.user=$DB_USER
flyway.password=$DB_PASS
flyway.placeholders.fqdn=$FQDN
flyway.placeholders.base_dir=/var/lib/ohmage" > /var/lib/ohmage/flyway/conf/flyway.conf

# create database stuffz. different depending on linked mysql container.
if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  echo -n "waiting for mysql to start..."
  while ! nc -w 1 $DB_HOST $DB_PORT &> /dev/null
  do
    echo -n .
    sleep 1
  done
  echo 'mysql available.'
  mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$DB_HOST -P$DB_PORT mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"
else
  service mysql start
  mysql -uroot mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"$DB_HOST\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"

fi

# execute migrations
/var/lib/ohmage/flyway/flyway migrate
 
# start tomcat in foreground
/usr/local/tomcat/bin/catalina.sh run