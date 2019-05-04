FROM php:7.1-apache
 
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
        libxml2-dev \
	libmagickwand-dev \
	libmagickcore-6.q16-3-extra

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
    pecl install redis-4.2.0; \
    pecl install xdebug; \
    pecl install imagick; \
    \
    docker-php-ext-enable \
        apcu \
        memcached \
        redis \
        xdebug \
	imagick

# dev tools 
RUN apt-get install -y --no-install-recommends \
    git curl vim sudo 

RUN bash -c 'echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini; \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" >> /usr/local/etc/php/conf.d/xdebug.ini \
'

RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini


RUN a2enmod rewrite

ADD configs/autoconfig_mysql.php configs/autoconfig_pgsql.php configs/autoconfig_oci.php configs/s3.php configs/config.php configs/redis.config.php /root/

ADD bootstrap.sh occ /usr/local/bin/

ENV WEBROOT /var/www/html

WORKDIR /var/www/html

ENTRYPOINT  ["/usr/local/bin/bootstrap.sh"]
CMD ["apache2-foreground"]
