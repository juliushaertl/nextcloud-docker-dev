FROM nextcloud:latest

RUN DEBIAN_FRONTEND=noninteractive ;\
	apt-get update && \
	apt-get install --assume-yes \
		cron sudo

RUN yes | pecl install xdebug
        
ADD configs/autoconfig_mysql.php configs/autoconfig_pgsql.php configs/autoconfig_oci.php configs/s3.php configs/config.php /root/

ADD misc/bootstrap.sh /usr/local/bin/

ENV WEBROOT /var/www/html

ENTRYPOINT  ["bootstrap.sh"]
