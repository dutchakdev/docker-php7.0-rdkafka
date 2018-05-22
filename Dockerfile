FROM debian:jessie

MAINTAINER Roman Dutchak "dutchakdev@gmail.com"
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.1
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apt-get update
RUN apt-get install -y curl
RUN echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
RUN curl -L https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update
RUN apt-get install -y php7.0 php7.0-redis php7.0-fpm php7.0-curl php7.0-gd php7.0-xml php7.0-dom php7.0-pdo php7.0-mysql php7.0-sqlite3 php7.0-intl php7.0-apc php7.0-dev
RUN apt-get -y install git libcurl4-gnutls-dev sendmail libpng-dev libxml2-dev unzip build-essential make libpthread-stubs0-dev zlibc && \
    apt-get install -y nginx python-software-properties software-properties-common
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* && \
    rm -rf /var/lib/apt/lists/* 
RUN mkdir -p /var/run/php/
RUN sed -i -e "s/;clear_env\s*=\s*no/clear_env = no/g" /etc/php/7.0/fpm/pool.d/www.conf

RUN \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

VOLUME ["/etc/nginx/conf.d", "/var/log/nginx", "/var/www/web", "/opt/"]
ADD ./bin/entrypoint.sh /opt/entrypoint.sh
ADD ./bin/run.sh /opt/run.sh
RUN chmod +x /opt/run.sh 
RUN chmod +x /opt/entrypoint.sh
RUN rm -rf /etc/nginx/sites-enabled/*

RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN "date"

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN HTTPDUSER=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1) && \
    setfacl -dR -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX var && \
    setfacl -R -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX var && \
    chmod -R 0777 var/

RUN git clone https://github.com/edenhill/librdkafka.git
RUN  cd /librdkafka/ && \
      ./configure && \
      make &&  \
      make install

RUN git clone https://github.com/arnaud-lb/php-rdkafka
RUN cd /php-rdkafka/ && \
    phpize && \
    ./configure && \
    make all -j 5 && \
    make install

EXPOSE 80
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/opt/run.sh"]