FROM composer as build

WORKDIR /app

COPY src .
COPY src/.env.prod ./.env
RUN composer install


# https://hub.docker.com/_/php
FROM php:8.0-apache

WORKDIR /var/www/html

# COPY src ./
COPY --from=build /app ./

RUN chmod -R a+x ./ \
    && chown -R www-data:www-data ./

# install libs
RUN apt-get update && \
    apt-get install -y \
    zip \
    unzip \
    curl \
    zlib1g-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
	&& apt-get clean -y

# PECL extensions
RUN pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-source delete

# supress warning: Set the 'ServerName' directive globally to suppress this message
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf 
COPY vhost.conf /etc/apache2/sites-available/000-default.conf

# mods
RUN a2enmod rewrite
RUN a2enmod actions

USER www-data

EXPOSE 8080