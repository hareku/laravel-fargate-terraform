FROM php:7.2-fpm

LABEL maintainer="hareku <hareku908@gmail.com>"

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    busybox-static \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql \
  && docker-php-ext-install pdo_pgsql \
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yqq && \
    apt-get install -y apt-utils && \
    pecl channel-update pecl.php.net

###########################################################################
# ZipArchive:
###########################################################################
RUN apt-get install libzip-dev -y && \
    docker-php-ext-configure zip --with-libzip && \
    docker-php-ext-install zip

###########################################################################
# Mysql Client:
###########################################################################
RUN apt-get install mysql-client -y

###########################################################################
# PHP Memcached:
###########################################################################
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz";
RUN mkdir -p memcached \
    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
        cd memcached \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r memcached \
    && rm /tmp/memcached.tar.gz \
    && docker-php-ext-enable memcached

###########################################################################
# PHP REDIS EXTENSION:
###########################################################################
RUN printf "\n" | pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

###########################################################################
# Image optimizers:
###########################################################################
RUN apt-get install -y jpegoptim optipng pngquant gifsicle

###########################################################################
# ImageMagick:
###########################################################################
RUN apt-get install -y libmagickwand-dev imagemagick && \
    pecl install imagick && \
    docker-php-ext-enable imagick

###########################################################################
# Crontab
###########################################################################
COPY ./crontab /var/spool/cron/crontabs/root

###########################################################################
# Opcache:
###########################################################################
RUN docker-php-ext-install opcache
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# Supervisor:
###########################################################################
RUN apt-get install -y --no-install-recommends supervisor \
  && rm -rf /var/lib/apt/lists/*

COPY ./supervisord.conf /etc/

COPY ./supervisord.d/crond.conf /etc/supervisord.d/
COPY ./supervisord.d/laravel-worker.conf /etc/supervisord.d/
COPY ./supervisord.d/php-fpm.conf /etc/supervisord.d/

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#
COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/
COPY ./php7.2.ini /usr/local/etc/php/php.ini

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

WORKDIR /etc/supervisor/conf.d/

EXPOSE 9000
