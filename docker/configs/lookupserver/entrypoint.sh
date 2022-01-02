#!/usr/bin/env bash
mysqld_safe &
sleep 5 && \
service cron start && \
rm /var/run/apache2/apache2.pid 2>/dev/null || true && \
mysql -u root -pabrakadabra -e "CREATE USER 'lookup' IDENTIFIED BY 'lookup'; GRANT USAGE ON lookup.* TO 'lookup'@'%' IDENTIFIED BY 'lookup'; GRANT ALL privileges ON lookup.* TO 'lookup'@'%'; FLUSH PRIVILEGES;" && \
mysql -u root -pabrakadabra < /root/mysql.dmp && \
/usr/sbin/apache2ctl -D FOREGROUND

