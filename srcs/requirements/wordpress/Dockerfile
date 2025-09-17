FROM debian:oldstable

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	lsb-release \
	ca-certificates \
	wget \
	gnupg2 \
	&& rm -rf /var/lib/apt/lists/*

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && apt-get install -y \
	php8.3-fpm \
	php8.3-mysql \
	php8.3-redis \
	php8.3-curl \
	php8.3-gd \
	php8.3-mbstring \
	php8.3-xml \
	php8.3-zip \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.3/fpm/pool.d/www.conf

COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/8.3/fpm/php-fpm.conf

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/sbin/php-fpm8.3", "-F"]
