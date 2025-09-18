FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg2 \
        apt-transport-https \
        lsb-release \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \

    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.3-fpm \
        php8.3-mysql \
        mariadb-client \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/www.conf /etc/php/8.3/fpm/pool.d/www.conf

RUN sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/8.3/fpm/php-fpm.conf

COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/sbin/php-fpm8.3", "-F"]