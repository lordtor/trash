FROM alpine:3.12
LABEL Maintainer="Yuriy Rumyantsev <yrumyantsev@homecredit.ru>" \
      Description="Composer PHP-FPM 7.3 Nginx 1.18 & based on Alpine Linux."


# Install packages and remove default server definition
RUN apk --no-cache add php7 php7-fpm php7-bcmath  php7-opcache wget php7-pdo_sqlite php7-zip php7-curl php7-fileinfo php7-sqlite3 php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-tokenizer php7-pdo  php7-pdo_mysql php7-pdo_pgsql php7-iconv php7-dom php7-xmlreader php7-soap php7-ctype php7-session \
    php7-mbstring php7-posix php7-simplexml php7-mcrypt php7-gd php7-mysqlnd nginx supervisor curl && \
    rm /etc/nginx/conf.d/default.conf

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

# Configure PHP
COPY config/php.ini /etc/php7/conf.d/custom.ini
# Setup document root
RUN mkdir -p /var/www/html
COPY src/ /var/www/html

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
# Make sure files/folders needed by the processes are accessable when they run under the nobody user

RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  addgroup nobody tty

USER nobody

# Add application
WORKDIR /var/www/html
RUN composer install

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

