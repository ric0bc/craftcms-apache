FROM php:7.0-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/web

WORKDIR /var/www/html

RUN apt-get update \
  && apt-get install -yq wget unzip vim libmagickwand-dev libzip-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && wget "https://craftcms.com/latest-v3.zip" -O craft.zip \
  && unzip -oq ./craft.zip \
  && chmod 777 -R config .env storage vendor web/cpresources \
  && rm -rf craft.zip
  
RUN docker-php-ext-install -j$(nproc) pdo_mysql \
  && pecl install imagick \
  && pecl install zip \
  && docker-php-ext-enable imagick zip

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf 
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN a2enmod rewrite

EXPOSE 80
