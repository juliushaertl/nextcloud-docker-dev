FROM nginxproxy/nginx-proxy:latest
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 1024m;'; \
      echo 'proxy_set_header Host $http_host;'; \
      echo 'proxy_set_header X-Real-IP $remote_addr;'; \
      echo 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;'; \
      echo 'proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;'; \
    } > /etc/nginx/conf.d/my_proxy.conf
