#!/usr/bin/env bash

# Enable xdebug by ENV variable
if [ 0 -ne "${PHP_ENABLE_XDEBUG:-0}" ] ; then
    docker-php-ext-enable xdebug
    echo "Enabled xdebug"
fi

export PS1="\e[0;35mphd \e[0;37m\u container \h \e[0;32m\w \e[0;0m\n$ "

# Execute CMD
exec "$@"