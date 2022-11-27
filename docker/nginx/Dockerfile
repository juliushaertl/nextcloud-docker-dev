FROM nginxproxy/nginx-proxy:latest
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 1024m;'; \
    } > /etc/nginx/conf.d/my_proxy.conf
