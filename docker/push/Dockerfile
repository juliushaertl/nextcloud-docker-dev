FROM alpine

RUN wget https://github.com/nextcloud/notify_push/releases/download/v0.6.3/notify_push-`uname -m`-unknown-linux-musl -O /notify_push && chmod +x /notify_push && /notify_push --version

EXPOSE 7867

CMD ["/notify_push"]
