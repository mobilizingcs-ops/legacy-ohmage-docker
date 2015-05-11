#!/usr/bin/env bash

set -e

# if a container is linked as 'mysql', this should exist
if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
  DB_PORT=$MYSQL_PORT_3306_TCP_PORT
else
  #assume no linked container. 
  DB_HOST=localhost
  DB_PORT=3306
fi
# use passed env variable or defaults
DB_NAME=${DB_NAME:-ohmage}
DB_USER=${DB_USER:-ohmage}
DB_PASS=${DB_PASS:-ohmage}
FQDN=${FQDN:-$HOSTNAME}
 
# update ohmage conf to point to correct db
sed -i "s/^db.jdbcurl.*/db.jdbcurl=jdbc:mysql:\/\/$DB_HOST:$DB_PORT\/$DB_NAME?characterEncoding=utf8/" /etc/ohmage.conf
sed -i "s/^db.username.*/db.username=$DB_USER/" /etc/ohmage.conf
sed -i "s/^db.password.*/db.password=$DB_PASS/" /etc/ohmage.conf
 
# update flyway conf
# note that the placeholders wont be updated at each boot.
echo "flyway.url=jdbc:mysql://$DB_HOST:$DB_PORT/$DB_NAME
flyway.user=$DB_USER
flyway.password=$DB_PASS
flyway.placeholders.fqdn=$FQDN
flyway.placeholders.base_dir=/var/lib/ohmage" > /var/lib/ohmage/flyway/conf/flyway.conf

# create database stuffz. different depending on linked mysql container.
if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$DB_HOST -P$DB_PORT mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"
else
  service mysql start
  mysql -uroot mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"$DB_HOST\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"

fi

# start nginx
chmod -R 0744 /var/www/webapps/survey
service nginx start

# execute migrations
/var/lib/ohmage/flyway/flyway migrate
 
# start tomcat in foreground
/usr/local/tomcat/bin/catalina.sh run