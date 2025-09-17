FROM debian:oldstable

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

VOLUME /var/lib/mysql

ENTRYPOINT ["entrypoint.sh"]

CMD ["mariadbd"]
