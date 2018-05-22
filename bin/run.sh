#!/usr/bin/env bash

# echo "Migration..." &&
/var/www/bin/wait-for-it.sh $MYSQL_HOST:$MYSQL_PORT -- echo "Successfully started mysql"
/usr/sbin/php-fpm7.0 -D -O &&
nginx
