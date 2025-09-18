FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server gosu && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306
VOLUME /var/lib/mysql

ENTRYPOINT ["entrypoint.sh"]
CMD ["mariadbd"]