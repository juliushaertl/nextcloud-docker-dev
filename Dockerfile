FROM php:7.0-apache
 
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev

RUN debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-install \
        exif \
        gd \
        intl \
        ldap \
        mcrypt \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        zip 

RUN pecl install APCu-5.1.11; \
    pecl install memcached-3.0.4; \
    pecl install redis-3.1.6; \
    pecl install xdebug \
    \
    docker-php-ext-enable \
        apcu \
        memcached \
        redis \
        xdebug

# dev tools 
RUN apt-get install -y --no-install-recommends \
    git curl vim sudo 

RUN bash -c 'echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/xdebug.ini \
'

ADD configs/autoconfig_mysql.php configs/autoconfig_pgsql.php configs/autoconfig_oci.php configs/s3.php configs/config.php /root/

ADD bootstrap.sh occ /usr/local/bin/

ENV WEBROOT /var/www/html

WORKDIR /var/www/html

ENTRYPOINT  ["/usr/local/bin/bootstrap.sh"]
CMD ["apache2-foreground"]
