FROM php:7.4.13-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data && \
    apt update && \
    apt install --no-install-recommends \
        unzip \
        libicu-dev \
        libvips-dev \
        libvips42 \
        git -y && \
    pecl install vips-1.0.12  && \
    docker-php-ext-install intl && \
    docker-php-ext-enable opcache vips && \
    apt -y purge \
        autoconf \
        automake \
        autotools-dev \
        libgcc-8-dev \
        g++-8 \
        g++ \
        gcc-8 \
        gcc \
        cpp-8 \
        cpp \
        libicu-dev \
        libvips-dev && \
    apt -y autoremove && \
    apt -y autoclean && \
    rm -rf /tmp/pear && \
    mkdir -p /var/www/.composer && \
    chown www-data:www-data /var/www/.composer

RUN a2enmod rewrite headers && \
    sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY --from=composer:2.0.7 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_HOME /var/www/.composer
COPY ./php.ini /usr/local/etc/php/conf.d/z-99-dev-php.ini:ro
