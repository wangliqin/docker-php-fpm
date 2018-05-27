
FROM php:7.2-fpm

LABEL maintainer="Pan Yongde <panyongde@gmail.com>"

#####################################
# Set Timezone
#####################################

ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#
# Installing tools and PHP extentions using "apt", "docker-php", "pecl",
#

# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
#         "libpng-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
  && rm -rf /var/lib/apt/lists/*


 
  # Install the PHP pdo_mysql extention
  RUN docker-php-ext-install pdo_mysql \
  # Install the PHP pdo_pgsql extention
  && docker-php-ext-install pdo_pgsql \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd


# always run apt update when start and after add new source list, then clean up at end.
RUN apt-get update -yqq

#
#--------------------------------------------------------------------------
# Mandatory Software's Installation
#--------------------------------------------------------------------------
#
# Mandatory Software's such as ("mcrypt", "pdo_mysql", "libssl-dev", ....)
# are installed on the base image 'laradock/php-fpm' image. If you want
# to add more Software's or remove existing one, you need to edit the
# base image (https://github.com/Laradock/php-fpm).
#

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# Optional Software's will only be installed if you set them to `true`
# in the `docker-compose.yml` before the build.
# Example:
#   - INSTALL_ZIP_ARCHIVE=true
#

###########################################################################
# SOAP:
###########################################################################

# ARG INSTALL_SOAP=false

# RUN if [ ${INSTALL_SOAP} = true ]; then \
#     # Install the soap extension
#     rm /etc/apt/preferences.d/no-debian-php && \
#     apt-get -y install libxml2-dev php-soap && \
#     docker-php-ext-install soap \
# ;fi

###########################################################################
# pgsql
###########################################################################

# ARG INSTALL_PGSQL=false

# RUN if [ ${INSTALL_PGSQL} = true ]; then \
#     # Install the pgsql extension
#     docker-php-ext-install pgsql \
# ;fi

###########################################################################
# pgsql client
###########################################################################

# ARG INSTALL_PG_CLIENT=false

# RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
#     # Create folders if not exists (https://github.com/tianon/docker-brew-debian/issues/65)
#     mkdir -p /usr/share/man/man1 && \
#     mkdir -p /usr/share/man/man7 && \
#     # Install the pgsql client
#     apt-get install -y postgresql-client \
# ;fi

###########################################################################
# xDebug:
###########################################################################

# ARG INSTALL_XDEBUG=false

# RUN if [ ${INSTALL_XDEBUG} = true ]; then \
#   # Install the xdebug extension
#   if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
#     pecl install xdebug-2.5.5; \
#   else \
#     pecl install xdebug; \
#   fi && \
#   docker-php-ext-enable xdebug \
# ;fi

# Copy xdebug configuration for remote debugging
# COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

###########################################################################
# Blackfire:
###########################################################################

# ARG INSTALL_BLACKFIRE=false

# RUN if [ ${INSTALL_XDEBUG} = false -a ${INSTALL_BLACKFIRE} = true ]; then \
#     version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
#     && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
#     && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
#     && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
#     && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
# ;fi

###########################################################################
# PHP REDIS EXTENSION
###########################################################################

# ARG INSTALL_PHPREDIS=false

# RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
#     # Install Php Redis Extension
#     printf "\n" | pecl install -o -f redis \
#     &&  rm -rf /tmp/pear \
#     &&  docker-php-ext-enable redis \
# ;fi

###########################################################################
# Swoole EXTENSION
###########################################################################

# ARG INSTALL_SWOOLE=false

# RUN if [ ${INSTALL_SWOOLE} = true ]; then \
#     # Install Php Swoole Extension
#     pecl install swoole \
#     &&  docker-php-ext-enable swoole \
# ;fi

###########################################################################
# MongoDB:
###########################################################################

# ARG INSTALL_MONGO=false

# RUN if [ ${INSTALL_MONGO} = true ]; then \
#     # Install the mongodb extension
#     pecl install mongodb && \
#     docker-php-ext-enable mongodb \
# ;fi

###########################################################################
# AMQP:
###########################################################################

# ARG INSTALL_AMQP=false

# RUN if [ ${INSTALL_AMQP} = true ]; then \
#     apt-get install librabbitmq-dev -y && \
#     # Install the amqp extension
#     pecl install amqp && \
#     docker-php-ext-enable amqp \
# ;fi

###########################################################################
# ZipArchive:
###########################################################################

# ARG INSTALL_ZIP_ARCHIVE=false

# RUN if [ ${INSTALL_ZIP_ARCHIVE} = true ]; then \
#     # Install the zip extension
#     docker-php-ext-install zip \
# ;fi

###########################################################################
# pcntl
###########################################################################

# ARG INSTALL_PCNTL=false
# RUN if [ ${INSTALL_PCNTL} = true]; then \
#     # Installs pcntl, helpful for running Horizon
#     docker-php-ext-install pcntl \
# ;fi

###########################################################################
# bcmath:
###########################################################################

RUN docker-php-ext-install bcmath

###########################################################################
# GMP (GNU Multiple Precision):
###########################################################################

# ARG INSTALL_GMP=false

# RUN if [ ${INSTALL_GMP} = true ]; then \
#     # Install the GMP extension
# 	apt-get install -y libgmp-dev && \
#     docker-php-ext-install gmp \
# ;fi

###########################################################################
# PHP Memcached:
###########################################################################

# ARG INSTALL_MEMCACHED=false

# RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
#     # Install the php memcached extension
#     curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
#     && mkdir -p memcached \
#     && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
#     && ( \
#         cd memcached \
#         && phpize \
#         && ./configure \
#         && make -j$(nproc) \
#         && make install \
#     ) \
#     && rm -r memcached \
#     && rm /tmp/memcached.tar.gz \
#     && docker-php-ext-enable memcached \
# ;fi

###########################################################################
# Exif:
###########################################################################

# ARG INSTALL_EXIF=false

# RUN if [ ${INSTALL_EXIF} = true ]; then \
#     # Enable Exif PHP extentions requirements
#     docker-php-ext-install exif \
# ;fi

###########################################################################
# PHP Aerospike:
###########################################################################

# USER root

# ARG INSTALL_AEROSPIKE=false

# RUN if [ ${INSTALL_AEROSPIKE} = true ]; then \
#     # Fix dependencies for PHPUnit within aerospike extension
#     apt-get -y install sudo wget && \
#     # Install the php aerospike extension
#     curl -L -o /tmp/aerospike-client-php.tar.gz ${AEROSPIKE_PHP_REPOSITORY} \
#     && mkdir -p aerospike-client-php \
#     && tar -C aerospike-client-php -zxvf /tmp/aerospike-client-php.tar.gz --strip 1 \
#     && ( \
#         cd aerospike-client-php/src \
#         && phpize \
#         && ./build.sh \
#         && make install \
#     ) \
#     && rm /tmp/aerospike-client-php.tar.gz \
#     && docker-php-ext-enable aerospike \
# ;fi

###########################################################################
# Opcache:
###########################################################################

# ARG INSTALL_OPCACHE=false

# RUN if [ ${INSTALL_OPCACHE} = true ]; then \
#     docker-php-ext-install opcache \
# ;fi

# Copy opcache configration
# COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

###########################################################################
# Mysqli Modifications:
###########################################################################

RUN docker-php-ext-install mysqli

###########################################################################
# Tokenizer Modifications:
###########################################################################

# ARG INSTALL_TOKENIZER=false

# RUN if [ ${INSTALL_TOKENIZER} = true ]; then \
#     docker-php-ext-install tokenizer \
# ;fi

###########################################################################
# Human Language and Character Encoding Support:
###########################################################################

# ARG INSTALL_INTL=false

# RUN if [ ${INSTALL_INTL} = true ]; then \
#     # Install intl and requirements
#     apt-get install -y zlib1g-dev libicu-dev g++ && \
#     docker-php-ext-configure intl && \
#     docker-php-ext-install intl \
# ;fi

###########################################################################
# GHOSTSCRIPT:
###########################################################################

# ARG INSTALL_GHOSTSCRIPT=false

# RUN if [ ${INSTALL_GHOSTSCRIPT} = true ]; then \
#     # Install the ghostscript extension
#     # for PDF editing
#     apt-get install -y \
#     poppler-utils \
#     ghostscript \
# ;fi

###########################################################################
# LDAP:
###########################################################################

# ARG INSTALL_LDAP=false

# RUN if [ ${INSTALL_LDAP} = true ]; then \
#     apt-get install -y libldap2-dev && \
#     docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
#     docker-php-ext-install ldap \
# ;fi

###########################################################################
# SQL SERVER:
###########################################################################

# ARG INSTALL_MSSQL=false

# RUN set -eux; if [ ${INSTALL_MSSQL} = true ]; then \
#     ###########################################################################
#     # Ref from https://github.com/Microsoft/msphpsql/wiki/Dockerfile-for-adding-pdo_sqlsrv-and-sqlsrv-to-official-php-image
#     ###########################################################################
#     # Add Microsoft repo for Microsoft ODBC Driver 13 for Linux
#     apt-get install -y apt-transport-https gnupg \
#     && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
#     && curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
#     && apt-get update -yqq \
#     # Install Dependencies
#     && ACCEPT_EULA=Y apt-get install -y unixodbc unixodbc-dev libgss3 odbcinst msodbcsql locales \
#     && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
#     && locale-gen \
#     # Install pdo_sqlsrv and sqlsrv from PECL. Replace pdo_sqlsrv-4.1.8preview with preferred version.
#     && pecl install pdo_sqlsrv-4.1.8preview sqlsrv-4.1.8preview \
#     && docker-php-ext-enable pdo_sqlsrv sqlsrv \
#     && php -m | grep -q 'pdo_sqlsrv' \
#     && php -m | grep -q 'sqlsrv' \
# ;fi

###########################################################################
# Image optimizers:
###########################################################################

# USER root

# ARG INSTALL_IMAGE_OPTIMIZERS=false

# RUN if [ ${INSTALL_IMAGE_OPTIMIZERS} = true ]; then \
#     apt-get install -y --force-yes jpegoptim optipng pngquant gifsicle \
# ;fi

###########################################################################
# ImageMagick:
###########################################################################

# USER root

# ARG INSTALL_IMAGEMAGICK=false

# RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
#     apt-get install -y libmagickwand-dev imagemagick && \
#     pecl install imagick && \
#     docker-php-ext-enable imagick \
# ;fi

###########################################################################
# IMAP:
###########################################################################

# ARG INSTALL_IMAP=false

# RUN if [ ${INSTALL_IMAP} = true ]; then \
#     apt-get install -y libc-client-dev libkrb5-dev && \
#     rm -r /var/lib/apt/lists/* && \
#     docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
#     docker-php-ext-install imap \
# ;fi

###########################################################################
# Check PHP version:
###########################################################################

# ARG PHP_VERSION=${PHP_VERSION}

# RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

#添加ini
COPY ./php72.ini /usr/local/etc/php/php.ini

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
