FROM nginx:alpine

COPY ./docker/nginx/nginx.conf /etc/nginx/
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash www-data

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server 127.0.0.1:9000; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

# Set application
COPY ./ /var/www

CMD ["nginx"]

EXPOSE 80
