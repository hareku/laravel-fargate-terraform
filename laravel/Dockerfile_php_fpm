FROM 1234567890.dkr.ecr.ap-northeast-1.amazonaws.com/application-php-fpm-base:latest

USER root

###########################################################################
# Composer:
###########################################################################
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

###########################################################################
# Application settings:
###########################################################################
COPY ./ /var/www
COPY docker/php-fpm/production.env /var/www/.env

WORKDIR /var/www

RUN chmod -R 777 /var/www/storage /var/www/bootstrap/cache
RUN php /usr/local/bin/composer install --optimize-autoloader --no-dev

RUN php artisan config:cache && \
    php artisan route:cache

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

WORKDIR /etc/supervisor/conf.d/

EXPOSE 9000
