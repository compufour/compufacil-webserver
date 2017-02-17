FROM php:7.1-alpine
ENV PHP_EXTRA_CONFIGURE_ARGS=" --enable-phpdbg --disable-session --with-mysql=shared,mysqlnd --with-mysqli=shared,mysqlnd --with-pdo-mysql=shared,mysqlnd"
RUN apk upgrade --update \
    && apk add libmcrypt libmcrypt-dev libpng libpng-dev icu-libs icu-dev \
        postgresql-dev mysql-dev libxml2-dev sqlite-dev autoconf alpine-sdk libmemcached-dev cyrus-sasl-dev gettext-dev \
        imagemagick-dev libtool busybox bash gettext

RUN docker-php-ext-install opcache mcrypt bcmath gd intl json pdo pdo_pgsql soap zip pdo_sqlite pcntl gettext session \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && pecl install imagick \
    && docker-php-ext-enable imagick

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk upgrade && \
    apk add apache2 apache2-dev php7.1-apache2 && \
    sed -i "s/php7.1_module/php7_module/g" /etc/apache2/conf.d/php7.1-module.conf && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    mkdir /run/apache2/

RUN rm -rf /etc/php7.1/conf.d && ln -s /usr/local/etc/php/conf.d /etc/php7.1/conf.d \
    && mkdir  /usr/lib/php7.1 \
    && ln -s /usr/local/lib/php/extensions/no-debug-non-zts-20160303 /usr/lib/php7.1/modules
VOLUME [ "/var/www/html" ]
WORKDIR /var/www/html/
ENTRYPOINT [ "/usr/sbin/httpd" ]
CMD ["-D", "FOREGROUND"]
