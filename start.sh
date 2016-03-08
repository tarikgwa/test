#!/bin/bash
set -e

#chown -R mysql:mysql /var/lib/mysql
#mysql_install_db --user mysql > /dev/null

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"1245nata"}
MYSQL_DATABASE=${MYSQL_DATABASE:-"magento"}
MYSQL_USER=${MYSQL_USER:-"911labs"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-"911labs"}

tfile=`mktemp`
if [[ ! -f "$tfile" ]]; then
    return 1
fi

cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

if [[ $MYSQL_DATABASE != "" ]]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

    if [[ $MYSQL_USER != "" ]]; then
        echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
    fi
fi

/usr/sbin/mysqld --bootstrap --verbose=0 $MYSQLD_ARGS < $tfile
rm -f $tfile
mysql -u 911labs --password=911labs magento < /var/www/html/magento.sql
# start all the services
/usr/local/bin/supervisord -n
supervisorctl reload
